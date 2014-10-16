node['backup_restore']['sources']['enabled'].each do |type|
  trigger = (type == 'mysql' || type == 'ruby') ? "#{type}_full" : type
  bash "run_backup_#{type}" do
    code "backup perform --trigger #{trigger} --config-file /etc/backup/config.rb --log-path=#{node['backup_restore']['log_dir']}"
    user node['backup_restore']['user']
  end
end
