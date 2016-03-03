default['tomcat']['base_version'] = 7
default['tomcat']['base_instance'] = "tomcat#{node['tomcat']['base_version']}"
default['tomcat']['deploy_manager_apps'] = false
default['tomcat']['packages'] = ["tomcat#{node['tomcat']['base_version']}"]
default['tomcat']['deploy_manager_packages'] = ["tomcat#{node['tomcat']['base_version']}-admin"]

case node['platform_family']

when 'rhel', 'fedora'
  suffix = node['tomcat']['base_version'].to_i < 7 ? node['tomcat']['base_version'] : ''

  default['tomcat']['base_instance'] = "tomcat#{suffix}"
  default['tomcat']['user'] = 'tomcat'
  default['tomcat']['group'] = 'tomcat'
  default['tomcat']['home'] = "/usr/share/tomcat#{suffix}"
  default['tomcat']['base'] = "/usr/share/tomcat#{suffix}"
  default['tomcat']['config_dir'] = "/etc/tomcat#{suffix}"
  default['tomcat']['log_dir'] = "/var/log/tomcat#{suffix}"
  default['tomcat']['tmp_dir'] = "/var/cache/tomcat#{suffix}/temp"
  default['tomcat']['work_dir'] = "/var/cache/tomcat#{suffix}/work"
  default['tomcat']['context_dir'] = "#{node['tomcat']['config_dir']}/Catalina/localhost"
  default['tomcat']['webapp_dir'] = "/var/lib/tomcat#{suffix}/webapps"
  default['tomcat']['keytool'] = 'keytool'
  default['tomcat']['lib_dir'] = "#{node['tomcat']['home']}/lib"
  default['tomcat']['endorsed_dir'] = "#{node['tomcat']['lib_dir']}/endorsed"
  default['tomcat']['packages'] = ["tomcat#{suffix}"]
  default['tomcat']['deploy_manager_packages'] = ["tomcat#{suffix}-admin-webapps"]
when 'debian'
  default['tomcat']['user'] = "tomcat#{node['tomcat']['base_version']}"
  default['tomcat']['group'] = "tomcat#{node['tomcat']['base_version']}"
  default['tomcat']['home'] = "/usr/share/tomcat#{node['tomcat']['base_version']}"
  default['tomcat']['base'] = "/var/lib/tomcat#{node['tomcat']['base_version']}"
  default['tomcat']['config_dir'] = "/etc/tomcat#{node['tomcat']['base_version']}"
  default['tomcat']['log_dir'] = "/var/log/tomcat#{node['tomcat']['base_version']}"
  default['tomcat']['tmp_dir'] = "/tmp/tomcat#{node['tomcat']['base_version']}-tmp"
  default['tomcat']['work_dir'] = "/var/cache/tomcat#{node['tomcat']['base_version']}"
  default['tomcat']['context_dir'] = "#{node['tomcat']['config_dir']}/Catalina/localhost"
  default['tomcat']['webapp_dir'] = "/var/lib/tomcat#{node['tomcat']['base_version']}/webapps"
  default['tomcat']['keytool'] = 'keytool'
  default['tomcat']['lib_dir'] = "#{node['tomcat']['home']}/lib"
  default['tomcat']['endorsed_dir'] = "#{node['tomcat']['lib_dir']}/endorsed"
when 'smartos'
  default['tomcat']['user'] = 'tomcat'
  default['tomcat']['group'] = 'tomcat'
  default['tomcat']['home'] = '/opt/local/share/tomcat'
  default['tomcat']['base'] = '/opt/local/share/tomcat'
  default['tomcat']['config_dir'] = '/opt/local/share/tomcat/conf'
  default['tomcat']['log_dir'] = '/opt/local/share/tomcat/logs'
  default['tomcat']['tmp_dir'] = '/opt/local/share/tomcat/temp'
  default['tomcat']['work_dir'] = '/opt/local/share/tomcat/work'
  default['tomcat']['context_dir'] = "#{node['tomcat']['config_dir']}/Catalina/localhost"
  default['tomcat']['webapp_dir'] = '/opt/local/share/tomcat/webapps'
  default['tomcat']['keytool'] = '/opt/local/bin/keytool'
  default['tomcat']['lib_dir'] = "#{node['tomcat']['home']}/lib"
  default['tomcat']['endorsed_dir'] = "#{node['tomcat']['home']}/lib/endorsed"
  default['tomcat']['packages'] = ['apache-tomcat']
  default['tomcat']['deploy_manager_packages'] = []
when 'suse'
  default['tomcat']['base_instance'] = 'tomcat'
  default['tomcat']['user'] = 'tomcat'
  default['tomcat']['group'] = 'tomcat'
  default['tomcat']['home'] = '/usr/share/tomcat'
  default['tomcat']['base'] = '/usr/share/tomcat'
  default['tomcat']['config_dir'] = '/etc/tomcat'
  default['tomcat']['log_dir'] = '/var/log/tomcat'
  default['tomcat']['tmp_dir'] = '/var/cache/tomcat/temp'
  default['tomcat']['work_dir'] = '/var/cache/tomcat/work'
  default['tomcat']['context_dir'] = "#{node['tomcat']['config_dir']}/Catalina/localhost"
  default['tomcat']['webapp_dir'] = '/srv/tomcat/webapps'
  default['tomcat']['keytool'] = 'keytool'
  default['tomcat']['lib_dir'] = "#{node['tomcat']['home']}/lib"
  default['tomcat']['endorsed_dir'] = "#{node['tomcat']['lib_dir']}/endorsed"
  default['tomcat']['packages'] = ['tomcat']
  default['tomcat']['deploy_manager_packages'] = ['tomcat-admin-webapps']
else
  default['tomcat']['user'] = "tomcat#{node['tomcat']['base_version']}"
  default['tomcat']['group'] = "tomcat#{node['tomcat']['base_version']}"
  default['tomcat']['home'] = "/usr/share/tomcat#{node['tomcat']['base_version']}"
  default['tomcat']['base'] = "/var/lib/tomcat#{node['tomcat']['base_version']}"
  default['tomcat']['config_dir'] = "/etc/tomcat#{node['tomcat']['base_version']}"
  default['tomcat']['log_dir'] = "/var/log/tomcat#{node['tomcat']['base_version']}"
  default['tomcat']['tmp_dir'] = "/tmp/tomcat#{node['tomcat']['base_version']}-tmp"
  default['tomcat']['work_dir'] = "/var/cache/tomcat#{node['tomcat']['base_version']}"
  default['tomcat']['context_dir'] = "#{node['tomcat']['config_dir']}/Catalina/localhost"
  default['tomcat']['webapp_dir'] = "/var/lib/tomcat#{node['tomcat']['base_version']}/webapps"
  default['tomcat']['keytool'] = 'keytool'
  default['tomcat']['lib_dir'] = "#{node['tomcat']['home']}/lib"
  default['tomcat']['endorsed_dir'] = "#{node['tomcat']['lib_dir']}/endorsed"
end
