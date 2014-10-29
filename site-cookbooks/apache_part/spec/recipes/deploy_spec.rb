require_relative '../spec_helper'

describe 'apache_part::deploy' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      cookbook_path: %w(cookbooks site-cookbooks),
      platform: 'centos',
      version: '6.5'
    ) do |node|
      node.set['cloudconductor']['applications'] = {
        test_ap_server: {},
        not_test_ap_server: {}
      }
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
    expect(chef_run).to create_template('/etc/httpd/conf/uriworkermap.properties').with(
      source: 'uriworkermap.properties.erb',
      mode: '0664',
      owner: 'apache',
      group: 'apache',
      variables: {
        app_name: 'test_ap_server'
      }
    )

    expect(chef_run).to_not create_template('/etc/httpd/conf/not-uriworkermap.properties').with(
      source: 'not-uriworkermap.properties.erb',
      mode: '0664',
      owner: 'foo',
      group: 'bar',
      variables: {
        app_name: 'not_test_ap_server'
      }
    )
  end

  let(:template) { chef_run.template('/etc/httpd/conf/uriworkermap.properties') }
  it 'reload apache2' do
    expect(template).to notify('service[apache2]').to(:reload).delayed
    expect(template).to_not notify('service[apache2]').to(:reload).immediately
  end
end
