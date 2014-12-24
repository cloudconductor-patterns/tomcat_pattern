require_relative '../spec_helper'

describe 'apache_part::deploy' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  app_name = 'application'

  before do
    chef_run.node.set['cloudconductor']['applications'] = {
      app_name =>  {}
    }
    chef_run.converge(described_recipe)
  end

  it 'create uriworkermap properties file' do
    expect(chef_run.node['apache']['conf_dir']).to eq('/etc/httpd/conf')
    chef_run.converge(described_recipe)

    expect(chef_run).to create_template('/etc/httpd/conf/uriworkermap.properties').with(
      source: 'uriworkermap.properties.erb',
      mode: '0664',
      variables: {
        app_name: app_name
      }
    )
  end

  it 'restart apaceh2 service' do
    service = chef_run.service('apache2')
    expect(service).to do_nothing
    expect(service.reload_command).to eq('/sbin/service httpd graceful')
    expect(chef_run.template('/etc/httpd/conf/uriworkermap.properties')).to notify('service[apache2]').to(:reload).delayed
  end
end
