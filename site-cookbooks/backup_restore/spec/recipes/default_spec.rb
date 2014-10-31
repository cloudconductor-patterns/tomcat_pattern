require_relative '../spec_helper'

describe 'backup_restore::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      cookbook_path: %w(site-cookbooks cookbooks),
      platform:      'centos',
      version:       '6.5'
    ).converge(described_recipe)
  end

  it 'include setup' do
    expect(chef_run).to include_recipe 'backup_restore::setup'
  end
end
