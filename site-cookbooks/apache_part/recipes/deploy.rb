template "#{node['apache']['conf_dir']}/uriworkermap.properties" do
  source 'uriworkermap.properties.erb'
  mode '0664'
  owner node['apache']['user']
  group node['apache']['group']
  variables(
    app_name: node['cloudconductor']['applications'].first.first
  )
end
