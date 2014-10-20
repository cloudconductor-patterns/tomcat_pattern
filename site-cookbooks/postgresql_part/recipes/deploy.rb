postgresql_connection_info = {
  host: '127.0.0.1',
  port: node['postgresql']['config']['port'],
  username: 'postgres',
  password: node['postgresql']['password']['postgres']
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

    postgresql_database app_name do
      connection postgresql_connection_info
      sql ::File.read("#{Chef::Config[:file_cache_path]}/#{app_name}.sql")
      action :query
    end
  end
end
