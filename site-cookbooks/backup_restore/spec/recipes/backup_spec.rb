require_relative '../spec_helper'

describe 'backup_restore::backup' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  describe 'postgres is includ backup enabled sources'do
    before do
      chef_run.node.set['backup_restore']['sources']['enabled'] = %w(postgresql)
      chef_run.converge(described_recipe)
    end

    it 'run backupf for postgresql' do
      log_dir = '/var/log/backup'
      user = 'root'
      expect(chef_run).to run_bash('run_backup_postgresql').with(
        code: "backup perform --trigger postgresql --config-file /etc/backup/config.rb --log-path=#{log_dir}",
        user: "#{user}"
      )
    end
  end
end
