require_relative '../spec_helper'
require 'chefspec'

describe 'postgresql_part::default' do
  let(:chef_run) do
    ChefSpec::Runner.new(
      cookbook_path: ['cookbooks', 'site-cookbooks'],
      platform: 'centos',
      version: '6.5'
    ).converge(described_recipe)
  end

  it 'include postgresql_part::setup' do
    expect(chef_run).to include_recipe 'postgresql_part::setup'
  end
end

