default['postgresql']['enable_pgdg_yum'] = true
default['postgresql']['version'] = '9.3'
default['postgresql']['client']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-devel"]
default['postgresql']['server']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-server"]
default['postgresql']['contrib']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-contrib"]
default['postgresql']['dir'] = "/var/lib/pgsql/#{node['postgresql']['version']}/data"
default['postgresql']['server']['service_name'] = "postgresql-#{node['postgresql']['version']}"
default['postgresql']['password']['postgres'] = 'todo_replace_random_password'
default['postgresql']['config']['listen_addresses'] = '*'
default['postgresql']['config']['data_directory'] = node['postgresql']['dir']

default['postgresql_part']['application']['database'] = 'application'
default['postgresql_part']['application']['user'] = 'application'
default['postgresql_part']['application']['password'] = 'todo_replace_random_password'
