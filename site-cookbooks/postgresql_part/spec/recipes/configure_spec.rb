require_relative '../spec_helper'
require 'chefspec'

describe 'postgresql_part::configure' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  port = '5432'
  dba_passwd = 'password'
  app_user = 'app_user'
  app_db = 'app_db'

  postgresql_connection_info = {
    host: '127.0.0.1',
    port: port,
    username: 'postgres',
    password: dba_passwd
  }

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
    allow_any_instance_of(Chef::Resource).to receive(:generate_password).and_return('GENERATED_PASSWORD')

    chef_run.node.set['postgresql']['config']['port'] = port
    chef_run.node.set['postgresql']['password']['postgres'] = dba_passwd
    chef_run.node.set['postgresql_part']['application']['user'] = app_user
    chef_run.node.set['postgresql_part']['application']['database'] = app_db

    chef_run.node.set['cloudconductor']['servers'] = {
      ap_server: {
        roles: 'ap',
        private_ip: ap_ip
      }
    }
    chef_run.node.set['postgresql']['dir'] = pgsql_dir
    chef_run.converge(described_recipe)
  end

  it 'create db user' do
    expect(chef_run).to ChefSpec::Matchers::ResourceMatcher.new(
      :postgresql_database_user,
      :create,
      app_user
    ).with(
      connection: postgresql_connection_info,
      password: 'GENERATED_PASSWORD'
    )
  end

  it 'create database' do
    expect(chef_run).to ChefSpec::Matchers::ResourceMatcher.new(
      :postgresql_database,
      :create,
      app_db
    ).with(
      connection: postgresql_connection_info,
      owner: app_user
    )
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
