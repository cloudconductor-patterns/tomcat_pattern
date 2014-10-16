tmp_dir = "#{node['backup_restore']['tmp_dir']}/restore"
source = node['backup_restore']['sources']['postgresql']
backup_name = 'postgresql'
backup_file = "#{tmp_dir}/#{backup_name}.tar"
backup_dir = "#{tmp_dir}/#{backup_name}/PostgreSQL.bkpdir"

# TODO: Create LWRP
bash 'extract_full_backup' do
  code <<-EOF
    tar -xvf #{backup_file} -C #{tmp_dir}
    tar -zxvf #{tmp_dir}/#{backup_name}/databases/PostgreSQL.tar.gz -C #{tmp_dir}/#{backup_name}
  EOF
  only_if { ::File.exist?(backup_file) && !::Dir.exist?("#{tmp_dir}/#{backup_name}") }
end

service "postgresql-#{source['version']}" do
  action :stop
  only_if { ::Dir.exist?(backup_dir) }
end

bash 'delete_old_data' do
  code "rm -rf #{source['data_dir']}/*"
  only_if { ::Dir.exist?(backup_dir) && !::Dir["#{source['data_dir']}/*"].empty? }
end

bash 'restore_backup' do
  code <<-EOF
    chown -R postgres:postgres #{source['data_dir']}
  EOF
  only_if { ::Dir.exist?(backup_dir) && ::Dir.exist?("#{tmp_dir}/#{backup_name}/PostgreSQL.bkpdir") }
end

service "postgresql-#{source['version']}" do
  action :start
  only_if { ::File.exist?(backup_file) }
end
