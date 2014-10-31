include_recipe 'apache2'
package "#{node['apache']['package']}-devel"

mod_jk_version = node['apache_part']['mod_jk']['version']
file_path = File.join(Chef::Config[:file_cache_path], "tomcat-connectors-#{mod_jk_version}-src.tar.gz")

remote_file 'tomcat_connectors' do
  source "http://www.apache.org/dist/tomcat/tomcat-connectors/jk/tomcat-connectors-#{mod_jk_version}-src.tar.gz"
  path file_path
  not_if { File.exist?("#{node['apache']['libexec_dir']}/mod_jk.so") }
end

bash 'install_mod_jk' do
  code <<-EOS
    tar -zxvf #{file_path}
    cd tomcat-connectors-#{mod_jk_version}-src/native
    if [ -z "$PKG_CONFIG_PATH" ]; then
      export PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/lib64/pkgconfig
    fi
    ./configure --with-apxs=/usr/sbin/apxs
    make
    make install
  EOS
  cwd Chef::Config[:file_cache_path]
  not_if { File.exist?("#{node['apache']['libexec_dir']}/mod_jk.so") }
end

file "#{node['apache']['conf_dir']}/workers.properties" do
  action :touch
end

file "#{node['apache']['conf_dir']}/uriworkermap.properties" do
  action :touch
end

template "#{node['apache']['dir']}/conf-available/mod-jk.conf" do
  source 'mod-jk.conf.erb'
  mode '0664'
  owner node['apache']['user']
  group node['apache']['group']
  variables({})
end

link "#{node['apache']['dir']}/conf-enabled/mod-jk.conf" do
  to "#{node['apache']['dir']}/conf-available/mod-jk.conf"
  notifies :reload, 'service[apache2]', :delayed
end
