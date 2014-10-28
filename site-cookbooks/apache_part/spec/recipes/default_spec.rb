require_relative '../spec_helper'

describe 'apache_part::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      cookbook_path: ['cookbooks', 'site-cookbooks'],
      platform: 'centos',
      version: '6.5'
    ).converge(described_recipe)
  end

  before do
    stub_command('/usr/sbin/httpd -t').and_return(0)
  end

  it 'install apache_part::setup' do
    expect(chef_run).to include_recipe('apache_part::setup')
  end
end
