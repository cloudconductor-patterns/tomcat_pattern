tmp_dir = "#{node['backup_restore']['tmp_dir']}/restore"
source = node['backup_restore']['sources']['postgresql']
backup_name = 'postgresql'
backup_file = "#{tmp_dir}/#{backup_name}.tar"

cmd = Mixlib::ShellOut.new('psql --version')
cmd.run_command
version = cmd.stdout.split(' ')[2]
major_version = version.split('.')[0].to_i
minor_version = version.split('.')[1].to_i

if major_version > 9 || (major_version == 9 && minor_version >= 3)
  terminate_session_sql = 'SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid();'
else
  terminate_session_sql = 'SELECT pg_terminate_backend(procpid) FROM pg_stat_activity WHERE procpid <> pg_backend_pid();'
end

# TODO: Create LWRP
bash 'extract_full_backup' do
  flags '-e'
  code <<-EOF
    tar -xvf #{backup_file} -C #{tmp_dir}
    gunzip #{tmp_dir}/#{backup_name}/databases/PostgreSQL.sql.gz
    sed -i -e "1i #{terminate_session_sql}" #{tmp_dir}/#{backup_name}/databases/PostgreSQL.sql
  EOF
  only_if { ::File.exist?(backup_file) && !::Dir.exist?("#{tmp_dir}/#{backup_name}") }
end

service "postgresql-#{source['version']}" do
  action :start
end

bash 'execute_restore_query' do
  code "/usr/bin/psql -f #{tmp_dir}/#{backup_name}/databases/PostgreSQL.sql"
  user 'postgres'
  only_if { ::File.exist?("#{tmp_dir}/#{backup_name}/databases/PostgreSQL.sql") }
end
