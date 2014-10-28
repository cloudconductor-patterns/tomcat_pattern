require_relative '../spec_helper'

describe 'apache_part::setup' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      cookbook_path: ['cookbooks', 'site-cookbooks'],
      platform: 'centos',
      version: '6.5'
    ) do |node|
      node.set['apache_part']['mod_jk']['version'] = '1.2.40'
      node.set['apache']['libexec_dir'] = '/usr/lib64/httpd/modules'
      node.set['apache']['conf_dir'] = '/etc/httpd/conf'
      node.set['apache']['dir'] = '/etc/httpd'
      node.set['apache']['user'] = 'apache'
      node.set['apache']['group'] = 'apache'
    end.converge(described_recipe)
  end

  before do
    stub_command('/usr/sbin/httpd -t').and_return(0)
    File.stub(:exists?).and_call_original
    File.stub(:exists?).with('/usr/lib64/httpd/modules/mod_jk.so').and_return('true')
  end

  it 'install apache2' do
    expect(chef_run).to include_recipe('apache2')
  end

  it 'installs a yum_package with httpd-devel' do
    expect(chef_run).to install_package('httpd-devel')
    expect(chef_run).to_not install_package('not_httpd-devel')
  end

  it 'Create tomcat_connectors' do
    expect(chef_run).to create_remote_file('tomcat_connectors').with(
      source: 'http://www.apache.org/dist/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.40-src.tar.gz',
      path: "#{Chef::Config[:file_cache_path]}/tomcat-connectors-1.2.40-src.tar.gz"
    )
  end

  it 'install mod_jk' do
    expect(chef_run).to run_bash('install_mod_jk').with(
      cwd: "#{Chef::Config[:file_cache_path]}",
      code: <<-EOS
    tar -zxvf #{Chef::Config[:file_cache_path]}/tomcat-connectors-1.2.40-src.tar.gz
    cd tomcat-connectors-1.2.40-src/native
    if [ -z "$PKG_CONFIG_PATH" ]; then
      export PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/lib64/pkgconfig
    fi
    ./configure --with-apxs=/usr/sbin/apxs
    make
    make install
  EOS
    )
  end

  it 'touches with workers.properties' do
    expect(chef_run).to touch_file('/etc/httpd/conf/workers.properties')
    expect(chef_run).to_not touch_file('/etc/httpd/conf/not_workers.properties')
  end

  it 'touches with uriworkermap.properties' do
    expect(chef_run).to touch_file('/etc/httpd/conf/uriworkermap.properties')
    expect(chef_run).to_not touch_file('/etc/httpd/conf/not_uriworkermap.properties')
  end

  it 'create template_file to mod-jk.conf' do
    expect(chef_run).to create_template('/etc/httpd/conf-available/mod-jk.conf').with(
      owner: 'apache',
      group: 'apache',
      mode: '0664',
      source: 'mod-jk.conf.erb'
    )
  end

  it 'create link to mod-jk.conf' do
    link = chef_run.link('/etc/httpd/conf-enabled/mod-jk.conf')
    expect(link).to link_to('/etc/httpd/conf-available/mod-jk.conf')
    expect(link).to_not link_to('/etc/httpd/conf-available/not-mod-jk.conf')
  end
end
