require_relative '../spec_helper'

describe 'backup_restore::fetch_s3' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  tmp_dir = '/tmp/backup'
  s3_bucket = 's3bucket'
  s3_prefix = '/backup'

  before do
    chef_run.node.set['backup_restore']['tmp_dir'] = tmp_dir
    chef_run.node.set['backup_restore']['destinations']['s3'] = {
      bucket: s3_bucket,
      prefix: s3_prefix
    }
    chef_run.converge(described_recipe)
  end

  describe 'postgresql is include restore target sources' do
    it 'download postgresql backup file' do
      source_name = 'postgresql'
      backup_name = source_name
      latest_backup_path = "s3://#{s3_bucket}/#{s3_prefix}/#{backup_name}/2014.10.01.00.00.00"

      chef_run.node.set['backup_restore']['restore']['target_sources'] = %w(source_name)

      allow(::File).to receive(:exist?).and_call_original
      allow(::File).to receive(:exist?).with("#{tmp_dir}/restore/#{backup_name}.tar").and_return(false)
      allow_any_instance_of(Mixlib::ShellOut).to receive(:run_command)
      allow_any_instance_of(Mixlib::ShellOut).to receive(:stdout).and_return("#{latest_backup_path}\n")

      chef_run.converge(described_recipe)

      expect(chef_run).to run_bash('download_backup_files').with(
        code: "/usr/bin/s3cmd get -r '#{latest_backup_path}' #{tmp_dir}/restore"
      )
    end
  end
end
