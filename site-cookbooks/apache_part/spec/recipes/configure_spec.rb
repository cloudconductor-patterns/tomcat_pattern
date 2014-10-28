require_relative '../spec_helper'

describe 'apache_part::configure' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      cookbook_path: ['cookbooks', 'site-cookbooks'],
      platform: 'centos',
      version: '6.5'
    ) do |node|
      node.set['cloudconductor']['servers'] = {
        test_ap_server: {
          roles: 'ap',
          private_ip: '10.0.0.3',
          weight: '1'
        }
      }
      node.set['apache_part']['sticky_session'] = 'true'
      node.set['apache']['conf_dir'] = '/etc/httpd/conf'
      node.set['apache']['user'] = 'apache'
      node.set['apache']['group'] = 'apache'
      node.set['apache']['package'] = 'httpd'
    end.converge(described_recipe)
  end

  before do
    stub_command('/usr/sbin/httpd -t').and_return(0)
  end

  it 'create template file' do
    expect(chef_run).to create_template('/etc/httpd/conf/workers.properties').with(
      source: 'workers.properties.erb',
      mode: '0664',
      owner: 'apache',
      group: 'apache',
      variables: {
        tomcat_servers: [
          'name' => 'test_ap_server',
          'host' => '10.0.0.3',
          'route' => '10.0.0.3',
          'weight' => '1'
        ],
        sticky_session: 'true'
      }
    )

    expect(chef_run).to_not create_template('/etc/httpd/conf/not-workers.properties').with(
      source: 'not-workers.properties.erb',
      mode: '0664',
      owner: 'foo',
      group: 'bar',
      variables: {
        tomcat_servers: [
          'name' => 'not_test_ap_server',
          'host' => '10.0.0.5',
          'route' => '10.0.0.5',
          'weight' => '2'
        ],
        sticky_session: 'false'
      }
    )
  end

  let(:template) { chef_run.template('/etc/httpd/conf/workers.properties') }
  it 'reload apache2' do
    expect(template).to notify('service[apache2]').to(:reload).delayed
    expect(template).to_not notify('service[apache2]').to(:reload).immediately
  end
end
