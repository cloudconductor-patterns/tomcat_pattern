include_recipe 'postgresql::server'
include_recipe 'postgresql::ruby'

# initdb
bash 'run_initdb' do
  code "service postgresql-#{node['postgresql']['version']} initdb"
  only_if { Dir.glob("#{node['postgresql']['dir']}/*").empty? }
end

postgresql_connection_info = {
  host: '127.0.0.1',
  port: node['postgresql']['config']['port'],
  username: 'postgres',
  password: node['postgresql']['password']['postgres']
}

postgresql_database_user node['postgresql_part']['application']['user'] do
  connection postgresql_connection_info
  password node['postgresql_part']['application']['password']
  action :create
end

postgresql_database node['postgresql_part']['application']['database'] do
  connection postgresql_connection_info
  owner node['postgresql_part']['application']['user']
  action :create
end
