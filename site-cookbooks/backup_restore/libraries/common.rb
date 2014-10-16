module BackupCommonHelper
  def store_with_s3
    s3_dst = node['backup_restore']['destinations']['s3']
    %(
      store_with S3 do |s3|
        s3.bucket = "#{s3_dst['bucket']}"
        s3.region = "#{s3_dst['region']}"
        s3.access_key_id = "#{s3_dst['access_key_id']}"
        s3.secret_access_key = "#{s3_dst['secret_access_key']}"
        s3.path = "#{s3_dst['prefix']}"
        s3.max_retries = 2
        s3.retry_waitsec = 10
      end
    )
  end

  def schedule_of(source, type = nil)
    schedule = node['backup_restore']['sources'][source]['schedule']
    schedule = schedule[type] unless type.nil?
    minute, hour, day, month, weekday = schedule.to_s.split
    {
      minute: minute,
      hour: hour,
      day: day,
      month: month,
      weekday: weekday
    }
  end

  def dynamic?
    -> (_, application) { application[:type] == 'dynamic' }
  end
end
