require_relative '../spec_helper'

describe 'backup_restore::backup' do
  let(:chef_run) do
    runner = ChefSpec::SoloRunner.new(
      cookbook_path: %w(site-cookbooks cookbooks),
      platform:      'centos',
      version:       '6.5'
    )do |node|
      node.set['backup_restore']['sources']['enabled'] =
       %w(postgresql)
    end
    runner.converge(described_recipe)
  end

  it 'run backup' do
    log_dir = '/var/log/backup'
    user = 'root'
    expect(chef_run).to run_bash('run_backup_postgresql').with(
      code: "backup perform --trigger postgresql --config-file /etc/backup/config.rb --log-path=#{log_dir}",
      user: "#{user}"
    )
  end
end
