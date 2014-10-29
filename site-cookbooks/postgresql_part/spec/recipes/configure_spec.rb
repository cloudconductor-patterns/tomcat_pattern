require_relative '../spec_helper'
require 'chefspec'

describe 'postgresql_part::configure' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      cookbook_path: ['cookbooks', 'site-cookbooks'],
      platform: 'centos',
      version: '6.5'
    ) do |node|
      node.set['cloudconductor']['servers'] = {
        test_ap_server: {
          roles: 'ap',
          private_ip: '172.0.0.1',
          weight: '1'
        }
      }
    end.converge(described_recipe)
  end

  it 'create pg_dba.conf' do
    expect(chef_run).to create_template('/var/lib/pgsql/9.3/data/pg_hba.conf').with(
      source: 'pg_hba.conf.erb',
      mode: '0644',
      owner: 'postgres',
      group: 'postgres',
      variables: {
        pg_hba: [
          { "type" => 'local', "db" => 'all', "user" => 'postgres', "addr" => nil, "method" => 'ident' },
          { "type" => 'local', "db" => 'all', "user" => 'all', "addr" => nil, "method" => 'ident' },
          { "type" => 'host', "db" => 'all', "user" => 'all', "addr" => '127.0.0.1/32', "method" => 'md5' },
          { "type" => 'host', "db" => 'all', "user" => 'all', "addr" => '::1/128', "method" => 'md5' },
          { "type" => 'host', "db" => 'all', "user" => 'postgres', "addr" => '0.0.0.0/0', "method" => 'reject' },
          { "type" => 'host', "db" => 'all', "user" => 'all', "addr" => '172.0.0.1/32', "method" => 'md5'}
        ]
      }
    )
  end

  let(:template) { chef_run.template('/var/lib/pgsql/9.3/data/pg_hba.conf') }
  it 'reload postgresql' do
    expect(template).to notify('service[postgresql]').to(:reload).delayed
  end
end

