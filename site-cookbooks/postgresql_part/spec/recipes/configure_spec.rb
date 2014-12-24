require_relative '../spec_helper'
require 'chefspec'

describe 'postgresql_part::configure' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  pgsql_dir = '/var/lib/pgsql/9.3/data'
  ap_ip = '172.0.0.1'
  pg_hda = [
    { 'type' => 'local', 'db' => 'all', 'user' => 'postgres', 'addr' => nil, 'method' => 'ident' },
    { 'type' => 'local', 'db' => 'all', 'user' => 'all', 'addr' => nil, 'method' => 'ident' },
    { 'type' => 'host', 'db' => 'all', 'user' => 'all', 'addr' => '127.0.0.1/32', 'method' => 'md5' },
    { 'type' => 'host', 'db' => 'all', 'user' => 'all', 'addr' => '::1/128', 'method' => 'md5' },
    { 'type' => 'host', 'db' => 'all', 'user' => 'postgres', 'addr' => '0.0.0.0/0', 'method' => 'reject' },
    { 'type' => 'host', 'db' => 'all', 'user' => 'all', 'addr' => "#{ap_ip}/32", 'method' => 'md5' }
  ]

  before do
    chef_run.node.set['cloudconductor']['servers'] = {
      ap_server: {
        roles: 'ap',
        private_ip: ap_ip
      }
    }
    chef_run.node.set['postgresql']['dir'] = pgsql_dir
    chef_run.converge(described_recipe)
  end

  it 'create pg_dba.conf' do
    expect(chef_run).to create_template("#{pgsql_dir}/pg_hba.conf").with(
      source: 'pg_hba.conf.erb',
      mode: '0644',
      owner: 'postgres',
      group: 'postgres',
      variables: {
        pg_hba: pg_hda
      }
    )
  end

  it 'restart posgresql service' do
    service_name = 'postgresql'
    chef_run.node.set['postgresql']['server']['service_name'] = service_name
    chef_run.converge(described_recipe)

    service = chef_run.service('postgresql')
    expect(service).to do_nothing
    expect(service.service_name).to eq(service_name)
    expect(chef_run.template("#{pgsql_dir}/pg_hba.conf")).to notify('service[postgresql]').to(:reload).delayed
  end
end
