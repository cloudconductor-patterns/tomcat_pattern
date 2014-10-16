# configure s3cmd
destinations = node['backup_restore']['destinations']
if destinations['enabled'].include?('s3')
  if node['backup_restore']['config']['use_proxy']
    proxy_config = {
      'proxy_host' => node['backup_restore']['config']['proxy_host'],
      'proxy_port' => node['backup_restore']['config']['proxy_port'],
      'use_https' => false
    }
  else
    proxy_config = {}
  end
  s3cfg "#{node['backup_restore']['home']}/.s3cfg" do
    access_key destinations['s3']['access_key_id']
    secret_key destinations['s3']['secret_access_key']
    owner node['backup_restore']['user']
    group node['backup_restore']['group']
    install_s3cmd false
    config proxy_config
  end
end

directory node['backup_restore']['log_dir'] do
  owner node['backup_restore']['user']
  group node['backup_restore']['group']
  action :create
end

# configure backup
node['backup_restore']['sources']['enabled'].each do |type|
  include_recipe "backup_restore::configure_#{type}"
end
