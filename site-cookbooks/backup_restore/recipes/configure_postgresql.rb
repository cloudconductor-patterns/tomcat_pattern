::Chef::Resource.send(:include, BackupCommonHelper)

source = node['backup_restore']['sources']['postgresql']

backup_model :postgresql do
  description 'Full Backup PostgreSQL database'
  definition <<-DEF
    split_into_chunks_of 4000

    database PostgreSQL do |db|
      db.name = :all
      db.host = "#{source['host']}"
      db.port = "#{source['port']}"
      db.username = "#{source['user']}"
      db.password = "#{source['password']}"
      db.additional_options = ["--clean"]
    end

    compress_with Gzip

    #{store_with_s3}
  DEF
  schedule(schedule_of('postgresql'))
  cron_options(
    path: ENV['PATH'],
    output_log: "#{node['backup_restore']['log_dir']}/backup.log"
  )
end

# set proxy environment if use_proxy
ruby_block 'set_proxy_env' do
  block do
    proxy_url = "http://#{node['backup_restore']['config']['proxy_host']}:#{node['backup_restore']['config']['proxy_port']}/"
    cron_file = '/etc/cron.d/postgresql_backup'
    file = Chef::Util::FileEdit.new(cron_file)
    file.insert_line_after_match(/# Crontab for/, "https_proxy=#{proxy_url}")
    file.insert_line_after_match(/# Crontab for/, "http_proxy=#{proxy_url}")
    file.write_file
    File.delete("#{cron_file}.old") if File.exist?("#{cron_file}.old")
  end
  only_if { node['backup_restore']['config']['use_proxy'] }
end
