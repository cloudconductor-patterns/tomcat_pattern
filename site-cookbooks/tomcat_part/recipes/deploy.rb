if node['cloudconductor']['servers']
  db_servers = node['cloudconductor']['servers'].select { |_, s| s['roles'].include?('db') }
  node.set['tomcat_part']['database']['host'] = db_servers.map { |_, s| s['private_ip'] }.first
end

applications = node['cloudconductor']['applications'].select { |_app_name, app| app['type'] == 'dynamic' }
applications.each do |app_name, app|
  case app['protocol']
  when 'git'
    source_path = File.join(Dir.tmpdir, app_name)

    deploy app_name do
      repo app['url']
      revision app['revision'] || 'HEAD'
      deploy_to source_path
      user node['tomcat']['user']
      group node['tomcat']['group']
      action :deploy
    end
  when 'http'
    source_path = File.join(Dir.tmpdir, "#{app_name}.war")

    remote_file app_name do
      source app['url']
      path source_path
      mode '0644'
      owner node['tomcat']['user']
      group node['tomcat']['group']
    end
  end

  bash app_name do
    code "mv #{source_path} #{node['tomcat']['webapp_dir']}"
  end

  app_dir = node['tomcat']['webapp_dir']

  bash "pre_deploy_script_#{app_name}" do
    cwd app_dir
    code app['pre_deploy']
    only_if { app['pre_deploy'] && !app['pre_deploy'].empty? }
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

  bash "post_deploy_script_#{app_name}" do
    cwd app_dir
    code app['post_deploy']
    only_if { app['post_deploy'] && !app['post_deploy'].empty? }
  end
end
