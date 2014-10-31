require_relative '../spec_helper'
require 'chefspec'

describe 'postgresql_part::deploy' do
  let(:chef_run_url) do
    ChefSpec::SoloRunner.new(
      cookbook_path: %w(cookbooks site-cookbooks),
      platform: 'centos',
      version: '6.5'
    ) do |node|
      node.set['cloudconductor']['applications'] = {
        app: {
          type: 'dynamic',
          parameters: {
            migration: {
              type: 'sql',
              url: 'http://example.com/migrate.sql'
            }
          }
        }
      }
    end.converge(described_recipe)
  end
  let(:chef_run_query) do
    ChefSpec::SoloRunner.new(
      cookbook_path: %w(cookbooks site-cookbooks),
      platform: 'centos',
      version: '6.5'
    ) do |node|
      node.set['cloudconductor']['applications'] = {
        app: {
          type: 'dynamic',
          parameters: {
            migration: {
              type: 'sql',
              query: 'foo'
            }
          }
        }
      }
    end.converge(described_recipe)
  end

  it 'download migration file' do
    expect(chef_run_url).to create_remote_file("#{Chef::Config[:file_cache_path]}/app.sql")
  end

  it 'create migration file' do
    expect(chef_run_query).to create_file("#{Chef::Config[:file_cache_path]}/app.sql").with(
      content: 'foo'
    )
  end

  postgresql_connection_info = {
    host: '127.0.0.1',
    port: 5432,
    username: 'application',
    password: 'todo_replace_random_password'
  }

  it 'run query' do
    expect(chef_run_url).to ChefSpec::Matchers::ResourceMatcher.new(
      :postgresql_database,
      :query,
      'application'
    ).with(
      connection: postgresql_connection_info
    )
  end

end
