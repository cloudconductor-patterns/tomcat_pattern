require_relative '../spec_helper'
require 'chefspec'

describe 'postgresql_part::default' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  port = '5432'
  dba_passwd = 'password'
  app_user = 'app_user'
  app_pass = 'app_pass'
  app_db = 'app_db'

  postgresql_connection_info = {
    host: '127.0.0.1',
    port: port,
    username: 'postgres',
    password: dba_passwd
  }

  before do
    stub_command('ls /var/lib/pgsql/9.3/data/recovery.conf')

    chef_run.node.set['postgresql']['config']['port'] = port
    chef_run.node.set['postgresql']['password']['postgres'] = dba_passwd
    chef_run.node.set['postgresql_part']['application']['user'] = app_user
    chef_run.node.set['postgresql_part']['application']['password'] = app_pass
    chef_run.node.set['postgresql_part']['application']['database'] = app_db
    chef_run.converge(described_recipe)
  end

  it 'include server recipe of postgresql cookbook' do
    expect(chef_run).to include_recipe 'postgresql::server'
  end

  it 'include ruby recipe of postgresql cookbook' do
    expect(chef_run).to include_recipe 'postgresql::ruby'
  end

  it 'create db user' do
    expect(chef_run).to ChefSpec::Matchers::ResourceMatcher.new(
      :postgresql_database_user,
      :create,
      app_user
    ).with(
      connection: postgresql_connection_info,
      password: app_pass
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
end
