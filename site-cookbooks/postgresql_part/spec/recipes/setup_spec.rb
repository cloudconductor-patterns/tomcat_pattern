require_relative '../spec_helper'
require 'chefspec'

describe 'postgresql_part::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      cookbook_path: %w(cookbooks site-cookbooks),
      platform: 'centos',
      version: '6.5'
    ).converge(described_recipe)
  end

  it 'include postgresql::server' do
    expect(chef_run).to include_recipe 'postgresql::server'
  end

  it 'include postgresql::server' do
    expect(chef_run).to include_recipe 'postgresql::server'
  end

  postgresql_connection_info = {
    host: '127.0.0.1',
    port: 5432,
    username: 'postgres',
    password: 'todo_replace_random_password'
  }

  it 'create db user' do
    expect(chef_run).to ChefSpec::Matchers::ResourceMatcher.new(
      :postgresql_database_user,
      :create,
      'application'
    ).with(
      connection: postgresql_connection_info,
      password: 'todo_replace_random_password'
    )
  end

  it 'create database' do
    expect(chef_run).to ChefSpec::Matchers::ResourceMatcher.new(
      :postgresql_database,
      :create,
      'application'
    ).with(
      connection: postgresql_connection_info,
      owner: 'application'
    )
  end
end
