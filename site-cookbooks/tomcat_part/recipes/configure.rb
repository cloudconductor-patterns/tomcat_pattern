if node['cloudconductor']['servers']
  db_servers = node['cloudconductor']['servers'].select { |_, s| s['roles'].include?('db') }
  node.set['tomcat_part']['database']['host'] = db_servers.map { |_, s| s['private_ip'] }.first
end

template "#{node['tomcat']['context_dir']}/context.xml" do
  source 'context.xml.erb'
  mode '0644'
  owner node['tomcat']['user']
  group node['tomcat']['group']
  variables(
    database: node['tomcat_part']['database'],
    datasource: node['tomcat_part']['datasource']
  )
end
