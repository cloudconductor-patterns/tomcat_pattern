tmp_dir = "#{node['backup_restore']['tmp_dir']}/restore"
source = node['backup_restore']['sources']['postgresql']
backup_name = 'postgresql'
backup_file = "#{tmp_dir}/#{backup_name}.tar"

# TODO: Create LWRP
bash 'extract_full_backup' do
  code <<-EOF
    tar -xvf #{backup_file} -C #{tmp_dir}
    gunzip #{tmp_dir}/#{backup_name}/databases/PostgreSQL.sql.gz
  EOF
  only_if { ::File.exist?(backup_file) && !::Dir.exist?("#{tmp_dir}/#{backup_name}") }
end

service "postgresql-#{source['version']}" do
  action :start
end

postgresql_connection_info = {
  host: '127.0.0.1',
  port: source['port'] || 5432,
  username: source['user'],
  password: source['password']
}

postgresql_database 'postgres' do
  connection postgresql_connection_info
  sql lazy { ::File.read("#{tmp_dir}/#{backup_name}/databases/PostgreSQL.sql") }
  action :query
  only_if { ::File.exist?("#{tmp_dir}/#{backup_name}/databases/PostgreSQL.sql") }
end
