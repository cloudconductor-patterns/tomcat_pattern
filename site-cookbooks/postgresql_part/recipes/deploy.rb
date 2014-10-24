postgresql_connection_info = {
  host: '127.0.0.1',
  port: node['postgresql']['config']['port'],
  username: node['postgresql_part']['application']['user'],
  password: node['postgresql_part']['application']['password']
}

applications = node['cloudconductor']['applications'].select { |_app_name, app| app['type'] == 'dynamic' }
applications.each do |app_name, app|
  next unless app['parameters'] && app['parameters']['migration']
  case app['parameters']['migration']['type']
  when 'sql'
    if app['parameters']['migration']['url']
      remote_file "#{Chef::Config[:file_cache_path]}/#{app_name}.sql" do
        source app['parameters']['migration']['url']
      end
    else
      file "#{Chef::Config[:file_cache_path]}/#{app_name}.sql" do
        content app['parameters']['migration']['query']
      end
    end

    postgresql_database "#{node['postgresql_part']['application']['database']}" do
      connection postgresql_connection_info
      sql lazy { ::File.read("#{Chef::Config[:file_cache_path]}/#{app_name}.sql") }
      action :query
    end
  end
end
