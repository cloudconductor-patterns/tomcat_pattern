require_relative '../spec_helper'

describe 'backup_restore::restore_postgresql' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  tmp_dir = '/tmp/backup/restore'
  backup_name = 'postgresql'
  backup_file = "#{tmp_dir}/#{backup_name}.tar"

  before do
    allow_any_instance_of(Mixlib::ShellOut).to receive(:run_command)
    allow_any_instance_of(Mixlib::ShellOut).to receive(:stdout).and_return('psql (PostgreSQL) 9.3.5')
  end

  it 'extract full backup data from backup archive' do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with(backup_file).and_return(true)
    allow(Dir).to receive(:exist?).and_call_original
    allow(Dir).to receive(:exist?).with("#{tmp_dir}/#{backup_name}").and_return(false)
    terminate_session_sql = 'SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid();'

    expect(chef_run).to run_bash('extract_full_backup').with(
      flags: '-e',
      code: <<-EOF
    tar -xvf #{backup_file} -C #{tmp_dir}
    gunzip #{tmp_dir}/#{backup_name}/databases/PostgreSQL.sql.gz
    sed -i -e "1i #{terminate_session_sql}" #{tmp_dir}/#{backup_name}/databases/PostgreSQL.sql
  EOF
    )
  end

  describe 'backup file is nothing' do
    it 'not extract full backup data from backup archive' do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(backup_file).and_return(false)
      expect(chef_run).to_not run_bash('extract_full_backup')
    end
  end

  describe 'extract the destination directory is exist' do
    it 'not extract full backup data from backup archive' do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(backup_file).and_return(true)
      allow(Dir).to receive(:exist?).and_call_original
      allow(Dir).to receive(:exist?).with("#{tmp_dir}/#{backup_name}").and_return(true)
      expect(chef_run).to_not run_bash('extract_full_backup')
    end
  end

  describe 'postgresql version is less than 9.3' do
    it 'extract full backup data from backup archive' do
      allow_any_instance_of(Mixlib::ShellOut).to receive(:stdout).and_return('psql (PostgreSQL) 9.2.0')
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(backup_file).and_return(true)
      allow(Dir).to receive(:exist?).and_call_original
      allow(Dir).to receive(:exist?).with("#{tmp_dir}/#{backup_name}").and_return(false)
      terminate_session_sql = 'SELECT pg_terminate_backend(procpid) FROM pg_stat_activity WHERE procpid <> pg_backend_pid();'

      expect(chef_run).to run_bash('extract_full_backup').with(
        flags: '-e',
        code: <<-EOF
    tar -xvf #{backup_file} -C #{tmp_dir}
    gunzip #{tmp_dir}/#{backup_name}/databases/PostgreSQL.sql.gz
    sed -i -e "1i #{terminate_session_sql}" #{tmp_dir}/#{backup_name}/databases/PostgreSQL.sql
  EOF
      )
    end
  end

  it 'service start' do
    version = '9.3'
    chef_run.node.set['backup_restore']['sources']['postgresql']['version'] = version
    expect(chef_run).to start_service("postgresql-#{version}")
  end

  it 'run restore query' do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with("#{tmp_dir}/#{backup_name}/databases/PostgreSQL.sql").and_return(true)
    expect(chef_run).to run_bash('execute_restore_query').with(
      code: "/usr/bin/psql -f #{tmp_dir}/#{backup_name}/databases/PostgreSQL.sql",
      user: 'postgres'
    )
  end

  describe 'fail extract backup sql' do
    it 'not run restore query' do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with("#{tmp_dir}/#{backup_name}/databases/PostgreSQL.sql").and_return(false)
      expect(chef_run).to_not run_bash('execute_restore_query')
    end
  end
end
