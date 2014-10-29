require_relative '../spec_helper'

describe 'tomcat_part::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      cookbook_path: %w(cookbooks site-cookbooks),
      platform: 'centos',
      version: '6.5'
    ) do |node|
      node.set['tomcat_part']['database']['type'] = 'postgresql'
      node.set['tomcat_part']['jdbc']['postgresql'] = 'http://jdbc.postgresql.org/download/postgresql-9.3-1102.jdbc41.jar'
      node.set['tomcat']['home'] = '/usr/share/tomcat7'
      node.set['tomcat']['user'] = 'tomcat'
      node.set['tomcat']['group'] = 'tomcat'
    end.converge(described_recipe)
  end

  it 'includes `tomcat_part` recipe' do
    expect(chef_run).to include_recipe('tomcat_part::setup')
  end

  it 'does not include `not_tomcat_part` recipe' do
    expect(chef_run).to_not include_recipe('not_tomcat_part::setup')
  end
end
