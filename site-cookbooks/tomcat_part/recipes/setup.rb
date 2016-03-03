if node['tomcat_part']['use_jpackage']
  package 'yum-plugin-priorities'

  remote_file "#{Chef::Config['file_cache_path']}/jpackage-release-6-3.jpp6.noarch.rpm" do
    source 'http://mirrors.dotsrc.org/jpackage/6.0/generic/free/RPMS/jpackage-release-6-3.jpp6.noarch.rpm'
  end

  package 'jpackage-release' do
    action :install
    source "#{Chef::Config['file_cache_path']}/jpackage-release-6-3.jpp6.noarch.rpm"
  end

  execute 'change gpgcheck' do
    command "sed -i 's/gpgcheck=1/gpgcheck=0/g' /etc/yum.repos.d/jpackage.repo"
  end
end

package 'java-1.5.0-gcj' if node[:platform_version].to_i <= 6

include_recipe 'java'
include_recipe 'tomcat'

# Install JDBC Driver
database_type = node['tomcat_part']['database']['type']
driver_url = node['tomcat_part']['jdbc'][database_type]
filename = File.basename(driver_url)

case filename
when /.*\.tar\.gz$/
  remote_file "#{Chef::Config[:file_cache_path]}/#{filename}" do
    source driver_url
  end

  bash 'extract_jdbc_driver' do
    code "tar -zxvf #{Chef::Config[:file_cache_path]}/#{filename} -C #{node['tomcat']['home']}/lib"
  end
else
  remote_file "#{node['tomcat']['home']}/lib/#{filename}" do
    source driver_url
  end
end

bash 'chown_tomcat_home' do
  code "chown #{node['tomcat']['user']}:#{node['tomcat']['group']} #{node['tomcat']['home']}"
end
