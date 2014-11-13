require_relative '../spec_helper'

describe 'backup_restore::configure_postgresql' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  it 'create clon backup' do
    log_dir = '2/var/log/backup'
    chef_run.node.set['backup_restore']['log_dir'] = log_dir
    chef_run.node.set['backup_restore']['sources']['postgresql']['schedule'] = '0 3 * * 0'
    chef_run.converge(described_recipe)

    expect(chef_run).to ChefSpec::Matchers::ResourceMatcher.new(
      :backup_model,
      :create,
      :postgresql
    ).with(
      description: 'Full Backup PostgreSQL database',
      schedule: {
        minute: '0',
        hour: '3',
        day: '*',
        month: '*',
        weekday: '0'
      },
      cron_options: {
        path: ENV['PATH'],
        output_log: "#{log_dir}/backup.log"
      }
    )
  end

  describe 'use proxy' do
    it 'set proxy env' do
      proxy_host = '127.0.0.250'
      proxy_port = '8080'
      chef_run.node.set['backup_restore']['config']['use_proxy'] = true
      chef_run.node.set['backup_restore']['config']['proxy_host'] = proxy_host
      chef_run.node.set['backup_restore']['config']['proxy_port'] = proxy_port
      chef_run.converge(described_recipe)

      expect(Chef::Util::FileEdit).to receive(:new)
        .with('/etc/cron.d/postgresql_backup').and_return(Chef::Util::FileEdit.new(Tempfile.new('chefspec')))
      expect_any_instance_of(Chef::Util::FileEdit).to receive(:insert_line_after_match)
        .with(/# Crontab for/, "https_proxy=http://#{proxy_host}:#{proxy_port}/")
      expect_any_instance_of(Chef::Util::FileEdit).to receive(:insert_line_after_match)
        .with(/# Crontab for/, "http_proxy=http://#{proxy_host}:#{proxy_port}/")
      expect_any_instance_of(Chef::Util::FileEdit).to receive(:write_file)
      chef_run.ruby_block('set_proxy_env').old_run_action(:create)
    end
  end
end
