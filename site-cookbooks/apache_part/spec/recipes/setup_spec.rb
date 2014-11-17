require_relative '../spec_helper'

describe 'apache_part::setup' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  before do
    stub_command('/usr/sbin/httpd -t').and_return(0)
    chef_run.converge(described_recipe)
  end

  it 'install apache2' do
    expect(chef_run).to include_recipe('apache2')
  end

  it 'install httpd-devel package' do
    expect(chef_run.node['apache']['package']).to eq('httpd')
    expect(chef_run).to install_package('httpd-devel')
  end

  describe 'mod_jk is not installed' do
    before do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('/usr/lib64/httpd/modules/mod_jk.so').and_return(false)
      chef_run.converge(described_recipe)
    end

    it 'download mod_jk archive file' do
      expect(chef_run).to create_remote_file('tomcat_connectors')
    end

    it 'install mod_jk' do
      expect(chef_run).to run_bash('install_mod_jk')
    end
  end

  describe 'mod_jk is installed' do
    before do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('/usr/lib64/httpd/modules/mod_jk.so').and_return(true)
      chef_run.converge(described_recipe)
    end

    it 'not download mod_jk archive file' do
      expect(chef_run).to_not create_remote_file('tomcat_connectors')
    end

    it 'not install mod_jk' do
      expect(chef_run).to_not run_bash('install_mod_jk')
    end
  end

  it 'create workers.properties' do
    expect(chef_run.node['apache']['conf_dir']).to eq('/etc/httpd/conf')
    expect(chef_run).to touch_file('/etc/httpd/conf/workers.properties')
  end

  it 'create uriworkermap.properties' do
    expect(chef_run.node['apache']['conf_dir']).to eq('/etc/httpd/conf')
    expect(chef_run).to touch_file('/etc/httpd/conf/uriworkermap.properties')
  end

  it 'create mod-jk.conf from template' do
    expect(chef_run.node['apache']['conf_dir']).to eq('/etc/httpd/conf')
    expect(chef_run).to create_template('/etc/httpd/conf-available/mod-jk.conf').with(
      mode: '0664',
      source: 'mod-jk.conf.erb'
    )
  end

  it 'create link to available mod-jk conf from enabled conf' do
    expect(chef_run.link('/etc/httpd/conf-enabled/mod-jk.conf')).to link_to('/etc/httpd/conf-available/mod-jk.conf')
  end
end
