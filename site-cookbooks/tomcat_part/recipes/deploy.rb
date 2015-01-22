if node['cloudconductor']['servers']
  db_servers = node['cloudconductor']['servers'].select { |_, s| s['roles'].include?('db') }
  node.set['tomcat_part']['database']['host'] = db_servers.map { |_, s| s['private_ip'] }.first
end

applications = node['cloudconductor']['applications'].select { |_app_name, app| app['type'] == 'dynamic' }
applications.each do |app_name, app|
  case app['protocol']
  when 'git'
    deploy app_name do
      repo app['url']
      revision app['revision'] || 'HEAD'
      deploy_to node['tomcat']['webapp_dir']
      user node['tomcat']['user']
      group node['tomcat']['group']
      action :deploy
    end
  when 'http'
    remote_file app_name do
      source app['url']
      path File.join(node['tomcat']['webapp_dir'], "#{app_name}.war")
      mode '0644'
      owner node['tomcat']['user']
      group node['tomcat']['group']
    end
  end
  template "#{node['tomcat']['context_dir']}/#{app_name}.xml" do
    source 'context.xml.erb'
    mode '0644'
    owner node['tomcat']['user']
    group node['tomcat']['group']
    variables(
      database: node['tomcat_part']['database'],
      password: generate_password('database'),
      datasource: node['tomcat_part']['datasource']
    )
  end
end
