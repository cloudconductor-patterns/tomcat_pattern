# set workers.properties
tomcat_servers = node['cloudconductor']['servers'].select { |_, s| s['roles'].include?('ap') }
tomcat_servers = tomcat_servers.map do |hostname, server|
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
  notifies :reload, 'service[apache2]', :delayed
end

service 'apache2' do
  service_name node['apache']['package']
  reload_command '/sbin/service httpd graceful'
  supports [:start, :restart, :reload, :status]
  action :nothing
end
