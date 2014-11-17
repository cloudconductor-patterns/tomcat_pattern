require_relative '../spec_helper'

describe 'backup_restore::default' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  it 'include setup recipe' do
    expect(chef_run).to include_recipe 'backup_restore::setup'
  end
end
