# setting pg_hba.conf
pg_hba = [
  { type: 'local', db: 'all', user: 'postgres', addr: nil, method: 'ident' },
  { type: 'local', db: 'all', user: 'all', addr: nil, method: 'ident' },
  { type: 'host', db: 'all', user: 'postgres', addr: '127.0.0.1/32', method: 'md5' },
  { type: 'host', db: 'all', user: 'postgres', addr: '0.0.0.0/0', method: 'reject' },
  { type: 'host', db: 'all', user: node['postgresql_part']['backup']['user'], addr: '127.0.0.1/32', method: 'md5' },
  { type: 'host', db: 'all', user: node['postgresql_part']['backup']['user'], addr: '0.0.0.0/0', method: 'reject' }
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
end

service "postgresql-#{node['postgresql']['version']}" do
  action :reload
end
