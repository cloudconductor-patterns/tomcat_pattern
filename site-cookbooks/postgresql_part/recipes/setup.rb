include_recipe 'postgresql::server'
include_recipe 'postgresql::ruby'

# initdb
bash 'run_initdb' do
  code "service postgresql-#{node['postgresql']['version']} initdb"
  only_if { Dir.glob("#{node['postgresql']['dir']}/*").empty? }
end
