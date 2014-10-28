require_relative '../spec_helper'

describe 'tomcat_part::deploy' do
  let(:chef_git_run) do
    ChefSpec::SoloRunner.new(
      cookbook_path: ['cookbooks', 'site-cookbooks'],
      platform: 'centos',
      version: '6.5'
    ) do |node|
      node.set['cloudconductor']['servers'] = {
        test_git_svr: {
          roles: 'db',
          private_ip: '10.0.0.3'
        }
      }
      node.set['cloudconductor']['applications'] = {
        test_git_app: {
          type: 'dynamic',
          protocol: 'git',
          revision: 'HEAD',
          url: 'https://github.com/test_git_app/test_git_app.git'
        }
      }
      node.set['tomcat']['user'] = 'tomcat'
      node.set['tomcat']['group'] = 'tomcat'
      node.set['tomcat']['webapp_dir'] = '/var/lib/tomcat7/webapps'
      node.set['tomcat']['context_dir'] = '/etc/tomcat7/Catalina/localhost'
      node.set['tomcat_part']['datasource'] = 'jdbc/test'
      node.set['tomcat_part']['database']['type'] = 'postgresql'
      node.set['tomcat_part']['database']['name'] = 'application'
      node.set['tomcat_part']['database']['user'] = 'application'
      node.set['tomcat_part']['database']['password'] = 'pass'
      node.set['tomcat_part']['database']['host'] = '10.0.0.3'
      node.set['tomcat_part']['database']['port'] = 5432
    end.converge(described_recipe)
  end
  let(:chef_http_run) do
    ChefSpec::SoloRunner.new(
      cookbook_path: ['cookbooks', 'site-cookbooks'],
      platform: 'centos',
      version: '6.5'
    ) do |node|
      node.set['cloudconductor']['servers'] = {
        test_http_svr: {
          roles: 'db',
          private_ip: '10.0.0.3'
        }
      }
      node.set['cloudconductor']['applications'] = {
        test_http_app: {
          type: 'dynamic',
          protocol: 'http',
          revision: 'HEAD',
          url: 'https://localhost/test_http_app.war'
        }
      }
      node.set['tomcat']['user'] = 'tomcat'
      node.set['tomcat']['group'] = 'tomcat'
      node.set['tomcat']['webapp_dir'] = '/var/lib/tomcat7/webapps'
      node.set['tomcat']['context_dir'] = '/etc/tomcat7/Catalina/localhost'
      node.set['tomcat_part']['datasource'] = 'jdbc/test'
      node.set['tomcat_part']['database']['type'] = 'postgresql'
      node.set['tomcat_part']['database']['name'] = 'application'
      node.set['tomcat_part']['database']['user'] = 'application'
      node.set['tomcat_part']['database']['password'] = 'pass'
      node.set['tomcat_part']['database']['host'] = '10.0.0.3'
      node.set['tomcat_part']['database']['port'] = 5432
    end.converge(described_recipe)
  end

  it 'deploy app_name' do
    expect(chef_git_run).to deploy_deploy('test_git_app').with(
      repo: 'https://github.com/test_git_app/test_git_app.git',
      revision: 'HEAD',
      deploy_to: '/var/lib/tomcat7/webapps',
      user: 'tomcat',
      group: 'tomcat'
    )
  end

  it 'remote_file app_name' do
    expect(chef_http_run).to create_remote_file('test_http_app').with(
      source: 'https://localhost/test_http_app.war',
      path: '/var/lib/tomcat7/webapps/test_http_app.war',
      mode: '0644',
      owner: 'tomcat',
      group: 'tomcat'
    )
  end

  it 'create template node["tomcat_part"]["context_dir"]/app_name.xml' do
    expect(chef_git_run).to create_template('/etc/tomcat7/Catalina/localhost/test_git_app.xml').with(
      source: 'context.xml.erb',
      mode: '0644',
      owner: 'tomcat',
      group: 'tomcat',
      variables: {
        database: {
          'type' => 'postgresql',
          'name' => 'application',
          'user' => 'application',
          'password' => 'pass',
          'host' => '10.0.0.3',
          'port' => 5432
        },
        datasource: 'jdbc/test'
      }
    )
  end
end
