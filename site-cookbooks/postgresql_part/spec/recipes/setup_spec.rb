require_relative '../spec_helper'
require 'chefspec'

describe 'postgresql_part::default' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  before do
    stub_command('ls /var/lib/pgsql/9.3/data/recovery.conf')
    chef_run.converge(described_recipe)
  end

  it 'include server recipe of postgresql cookbook' do
    expect(chef_run).to include_recipe 'postgresql::server'
  end

  it 'include ruby recipe of postgresql cookbook' do
    expect(chef_run).to include_recipe 'postgresql::ruby'
  end
end
