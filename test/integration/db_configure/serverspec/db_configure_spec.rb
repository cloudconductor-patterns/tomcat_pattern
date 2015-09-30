require 'spec_helper'

describe port(5432) do
  it { should be_listening.with('tcp') }
end

describe 'postgresql server' do
  hostname = '127.0.0.1'
  port = '5432'
  database = 'postgres'
  root_user = 'postgres'

  params = property[:consul_parameters]

  if params[:postgresql] && params[:postgresql]['password'] && params[:postgresql]['password']['postgres']
    root_passwd = params[:postgresql]['password']['postgres']
  else
    root_passwd = 'todo_replace_random_password'
  end

  if params['postgresql_part'] && params['postgresql_part']['application'] && params['postgresql_part']['application']['database']
    app_db = params['postgresql_part']['application']['database']
  else
    app_db = 'application'
  end

  if params['postgresql_part'] && params['postgresql_part']['application'] && params['postgresql_part']['application']['user']
    app_user = params['postgresql_part']['application']['user']
  else
    app_user = 'postgres'
  end

  if params['postgresql_part'] && params['postgresql_part']['application'] && params['postgresql_part']['application']['password']
    app_passwd = params['postgresql_part']['application']['password']
  else
    app_passwd = 'todo_replace_random_password'
  end

  before(:all) do
    Specinfra.backend.run_command(<<-EOS
      echo #{hostname}:#{port}:#{database}:#{root_user}:#{root_passwd} > ~/.pgpass
      echo #{hostname}:#{port}:#{app_db}:#{app_user}:#{app_passwd} >> ~/.pgpass
      chmod 600 ~/.pgpass
      EOS
                                 )
  end

  describe command("psql -U #{root_user} -d #{database} -h #{hostname} -p #{port} -c '\\l'") do
    its(:exit_status) { should eq 0 }
  end

  describe command("psql -U #{app_user} -d #{app_db} -h #{hostname} -p #{port} -c '\\l'") do
    its(:exit_status) { should eq 0 }
  end

  after(:all) do
    Specinfra.backend.run_command('rm -f ~/.pgpass')
  end
end
