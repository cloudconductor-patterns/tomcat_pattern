require_relative '../spec_helper'
require 'chefspec'

describe 'postgresql_part::deploy' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  app_name = 'app'

  describe 'dynamic type application is included "cloudconductor applications"' do
    before do
      chef_run.node.set['cloudconductor']['applications'] = {
        app_name => {
          type: 'dynamic'
        }
      }
      chef_run.converge(described_recipe)
    end

    describe 'migration type is sql' do
      before do
        chef_run.node.set['cloudconductor']['applications'][app_name]['parameters'] = {
          migration: {
            type: 'sql'
          }
        }
        chef_run.converge(described_recipe)
      end

      describe 'migration url is included applications parameter' do
        it 'download migration file' do
          url = 'http://cloudconductor.org/migration.sql'
          chef_run.node.set['cloudconductor']['applications'][app_name]['parameters']['migration']['url'] = url
          chef_run.converge(described_recipe)
          expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/#{app_name}.sql").with(
            source: url
          )
        end
      end

      describe 'migration type is not included' do
        it 'create migration file' do
          query = 'migration sql strings'
          chef_run.node.set['cloudconductor']['applications'][app_name]['parameters']['migration']['query'] = query
          chef_run.converge(described_recipe)
          expect(chef_run).to create_file("#{Chef::Config[:file_cache_path]}/app.sql").with(
            content: query
          )
        end
      end

      describe 'tables is not exist in postgresql db' do
        it 'do migration' do
          db_host = '127.0.0.1'
          db_port = '5432'
          db_user = 'pgsql'

          postgresql_connection_info = {
            host: db_host,
            port: db_port,
            username: db_user,
            password: /[0-9a-f]{32}/
          }

          chef_run.node.set['postgresql']['config']['port'] = db_port
          chef_run.node.set['postgresql_part']['application']['user'] = db_user

          db_name = 'app_db'
          chef_run.node.set['postgresql_part']['application']['database'] = db_name

          allow_any_instance_of(Mixlib::ShellOut).to receive(:runcommand)
          allow_any_instance_of(Mixlib::ShellOut).to receive(:stdout).and_return('0')

          chef_run.converge(described_recipe)

          expect(chef_run).to ChefSpec::Matchers::ResourceMatcher.new(
            :postgresql_database,
            :query,
            db_name
          ).with(
            connection: hash_including(postgresql_connection_info)
          )
        end
      end

      describe 'tables is exist in postgresql db' do
        it 'do not migration' do
          db_name = 'app_db'
          chef_run.node.set['postgresql_part']['application']['database'] = db_name

          allow_any_instance_of(Mixlib::ShellOut).to receive(:runcommand)
          allow_any_instance_of(Mixlib::ShellOut).to receive(:stdout).and_return('1')
          chef_run.converge(described_recipe)

          expect(chef_run).to_not ChefSpec::Matchers::ResourceMatcher.new(
            :postgresql_database,
            :query,
            db_name
          )
        end
      end
    end
  end
end
