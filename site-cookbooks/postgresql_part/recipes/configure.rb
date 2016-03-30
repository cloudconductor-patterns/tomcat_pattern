bash 'create_pid_file' do
  pid_file = "/var/run/#{node['postgresql']['server']['service_name']}.pid"
  lock_file = "/var/lock/subsys/#{node['postgresql']['server']['service_name']}"
  postmaster_file = "#{node['postgresql']['dir']}/postmaster.pid"
  code <<-EOS
    if [ ! -f #{postmaster_file} ]; then
      exit 1
    fi
    head -n 1 #{postmaster_file} > #{pid_file}
    touch #{lock_file}
  EOS
  not_if { ::File.exist?(pid_file) }
  retries 5
end

postgresql_connection_info = {
  host: '127.0.0.1',
  port: node['postgresql']['config']['port'],
  username: 'postgres',
  password: node['postgresql']['password']['postgres']
}

postgresql_database_user node['postgresql_part']['application']['user'] do
  connection postgresql_connection_info
  password generate_password('database')
  action :create
end

postgresql_database node['postgresql_part']['application']['database'] do
  connection postgresql_connection_info
  owner node['postgresql_part']['application']['user']
  action :create
end

# setting pg_hba.conf
pg_hba = [
  { type: 'local', db: 'all', user: 'postgres', addr: nil, method: 'ident' },
  { type: 'local', db: 'all', user: 'all', addr: nil, method: 'ident' },
  { type: 'host', db: 'all', user: 'all', addr: '127.0.0.1/32', method: 'md5' },
  { type: 'host', db: 'all', user: 'all', addr: '::1/128', method: 'md5' },
  { type: 'host', db: 'all', user: 'postgres', addr: '0.0.0.0/0', method: 'reject' }
]
ap_servers = node['cloudconductor']['servers'].select { |_name, server| server['roles'].include?('ap') }
pg_hba += ap_servers.map do |_name, server|
  { type: 'host', db: 'all', user: 'all', addr: "#{server['private_ip']}/32", method: 'md5' }
end
node.set['postgresql']['pg_hba'] = pg_hba

template "#{node['postgresql']['dir']}/pg_hba.conf" do
  source 'pg_hba.conf.erb'
  mode '0644'
  owner 'postgres'
  group 'postgres'
  variables(
    pg_hba: node['postgresql']['pg_hba']
  )
  notifies :reload, 'service[postgresql]', :delayed
end

service 'postgresql' do
  service_name node['postgresql']['server']['service_name']
  supports [:restart, :reload, :status]
  action :nothing
end
