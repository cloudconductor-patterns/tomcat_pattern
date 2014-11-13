require_relative '../spec_helper'

describe 'apache_part::configure' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  server_name = 'cehfs'
  private_ip = '172.0.0.1'

  before do
    chef_run.node.set['cloudconductor']['servers'] = {
      server_name => {
        roles: 'ap',
        private_ip: private_ip
      }
    }
    chef_run.converge(described_recipe)
  end

  it 'create template file' do
    sticky_session = true
    chef_run.node.set['apache_part']['sticky_session'] = sticky_session
    chef_run.converge(described_recipe)

    expect(chef_run.node['apache']['conf_dir']).to eq('/etc/httpd/conf')
    expect(chef_run).to create_template('/etc/httpd/conf/workers.properties').with(
      source: 'workers.properties.erb',
      mode: '0664',
      variables: {
        tomcat_servers: [
          'name' => server_name,
          'host' => private_ip,
          'route' => private_ip,
          'weight' => 1
        ],
        sticky_session: sticky_session
      }
    )
  end

  it 'restart apaceh2 service' do
    service = chef_run.service('apache2')
    expect(service).to do_nothing
    expect(service.reload_command).to eq('/sbin/service httpd graceful')
    expect(chef_run.template('/etc/httpd/conf/workers.properties')).to notify('service[apache2]').to(:reload).delayed
  end
end
