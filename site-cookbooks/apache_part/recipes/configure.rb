# set workers.properties
tomcat_servers = node['cloudconductor']['servers'].map do |hostname, server|
  {
    'name' => hostname,
    'host' => server['private_ip'],
    'route' => server['private_ip'],
    'weight' => server['weight'] || 1
  }
end

template "#{node['apache']['conf_dir']}/workers.properties" do
  source 'workers.properties.erb'
  mode '0664'
  owner node['apache']['user']
  group node['apache']['group']
  variables(
    tomcat_servers: tomcat_servers,
    sticky_session: node['apache_part']['sticky_session']
  )
end

service 'httpd' do
  action :reload
end
