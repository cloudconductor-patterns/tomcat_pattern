# Create temporary directory
directory "#{node['backup_restore']['tmp_dir']}/restore" do
  recursive true
  action :create
end

# Download backup files
restore_source = node['backup_restore']['destinations']['enabled'].first
include_recipe "backup_restore::fetch_#{restore_source}"

# Run restore
node['backup_restore']['restore']['target_sources'].each do |source_type|
  include_recipe "backup_restore::restore_#{source_type}"
end

# Remove temporary directory
directory "#{node['backup_restore']['tmp_dir']}/restore" do
  recursive true
  action :delete
end
