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
end
