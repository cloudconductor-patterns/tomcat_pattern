include_recipe 'cron'

package 'zlib-devel' do
  action :install
end

package 'xz-devel' do
  action :install
end

# install gem backup with options --no-ri --no-rdoc before include_recipe 'backup'
gem_package 'backup' do
  version node['backup']['version'] if node['backup']['version']
  action :upgrade if node['backup']['upgrade?']
  options '--no-ri --no-rdoc'
end
include_recipe 'backup'
include_recipe 'percona::backup'
link '/usr/local/bin/backup' do
  to '/root/.chefdk/gem/ruby/2.1.0/bin/backup'
  only_if { File.exist?('/root/.chefdk/gem/ruby/2.1.0/bin/backup') }
end

# for s3
include_recipe 'yum-epel'
include_recipe 's3cmd-master'
package 'python-dateutil'
