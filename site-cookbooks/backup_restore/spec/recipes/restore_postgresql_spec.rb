require_relative '../spec_helper'

describe 'backup_restore::restore_postgresql' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(
      cookbook_path: %w(site-cookbooks cookbooks),
      platform:      'centos',
      version:       '6.5'
    ).converge(described_recipe)
  end

  tmp_dir = '/tmp/backup/restore'
  backup_name = 'postgresql'
  backup_file = "#{tmp_dir}/#{backup_name}.tar"

  describe 'Installed PostgreSQL version 9.3.5' do

    before do
      expect_any_instance_of(Chef::Recipe).to receive(:`).and_return('psql (PostgreSQL) 9.3.5')
    end

    it 'extract_full_backup' do
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

    it 'service start' do
      expect(chef_run).to start_service('postgresql-9.3')
    end
    it 'service start' do
      expect(chef_run).to start_service('postgresql-9.3')
    end

    it 'run query for postgresql ' do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with("#{tmp_dir}/#{backup_name}/databases/PostgreSQL.sql").and_return(true)
      expect(chef_run).to run_bash('execute_restore_query').with(
        code: "/usr/bin/psql -f #{tmp_dir}/#{backup_name}/databases/PostgreSQL.sql",
        user: 'postgres'
      )
    end
  end

  describe 'Installed PostgreSQL version is other' do
    it 'extract_full_backup' do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(backup_file).and_return(true)
      allow(Dir).to receive(:exist?).and_call_original
      allow(Dir).to receive(:exist?).with("#{tmp_dir}/#{backup_name}").and_return(false)
      expect_any_instance_of(Chef::Recipe).to receive(:`).and_return('psql (PostgreSQL) 9.2.0')
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
end
