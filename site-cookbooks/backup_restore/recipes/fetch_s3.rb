require 'uri'

s3 = node['backup_restore']['destinations']['s3']
tmp_dir = "#{node['backup_restore']['tmp_dir']}/restore"

node['backup_restore']['restore']['target_sources'].each do |source_type|
  # Find latest backup on S3
  if %w(mysql ruby).include?(source_type)
    backup_name = "#{source_type}_full"
  else
    backup_name = source_type
  end
  s3_path = URI.join("s3://#{s3['bucket']}", File.join(s3['prefix'], backup_name, '/')).to_s
  datetime_regexp = '[0-9]\{4\}.[0-9]\{2\}.[0-9]\{2\}.[0-9]\{2\}.[0-9]\{2\}.[0-9]\{2\}/$'

  s3cmd = Mixlib::ShellOut.new("/usr/bin/s3cmd ls #{s3_path} | grep '#{datetime_regexp}' | sort | awk 'END{print $2}'")
  s3cmd.run_command
  latest_backup_path = s3cmd.stdout.chomp

  # Download backup from S3
  bash 'download_backup_files' do
    code "/usr/bin/s3cmd get -r '#{latest_backup_path}' #{tmp_dir}"
    not_if { ::File.exist?("#{tmp_dir}/#{backup_name}.tar") || latest_backup_path.empty? }
  end
end
