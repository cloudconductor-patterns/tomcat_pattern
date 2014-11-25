require_relative '../spec_helper'

describe 'backup_restore::restore' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  tmp_dir = '/tmp/backup'

  before do
    chef_run.node.set['backup_restore']['tmp_dir'] = tmp_dir
    chef_run.node.set['backup_restore']['destinations']['enabled'] = %w(s3)
    chef_run.converge(described_recipe)
  end

  it 'create temporary directory' do
    expect(chef_run).to create_directory("#{tmp_dir}/restore").with(
      recursive: true
    )
  end

  it 'fetch s3' do
    expect(chef_run).to include_recipe('backup_restore::fetch_s3')
  end

  describe 'postgresql is included restare sources' do
    it 'include restore_postgresql recipe' do
      chef_run.node.set['backup_restore']['destinations']['s3'] = {
        bucket: 's3bucket'
      }
      chef_run.node.set['backup_restore']['restore']['target_sources'] = %w(postgresql)

      allow_any_instance_of(Mixlib::ShellOut).to receive(:run_command)
      allow_any_instance_of(Mixlib::ShellOut).to receive(:stdout).and_return('psql (PostgreSQL) 9.3.5')

      chef_run.converge(described_recipe)

      expect(chef_run).to include_recipe('backup_restore::restore_postgresql')
    end
  end

  it 'delete temporary directory' do
    expect(chef_run).to delete_directory("#{tmp_dir}/restore").with(
      recursive: true
    )
  end
end
