require_relative '../spec_helper'

describe 'tomcat_part::deploy' do
  let(:chef_run) { ChefSpec::SoloRunner.new }

  app_name = 'application'
  db_private_ip = '172.0.0.10'

  before do
    chef_run.node.set['cloudconductor']['servers'] = {
      db: {
        roles: 'db',
        private_ip: db_private_ip
      }
    }
    chef_run.node.set['cloudconductor']['applications'] = {
      app_name => {}
    }
    chef_run.converge(described_recipe)
  end

  describe 'dynamic type applications are included in "cloudconductor applications"' do
    before do
      chef_run.node.set['cloudconductor']['applications'] = {
        app_name => {
          type: 'dynamic'
        }
      }
      chef_run.converge(described_recipe)
    end

    describe 'application deploy protocol is git' do
      it 'application deploy from git' do
        git_url = 'https://github.com/cloudconductor/cloud_conductor.git'
        git_version = '0.3'
        tomcat_user = 'tomcat'
        tomcat_group = 'passwd'
        tomcat_webapp_dir = '/var/lib/tomcat7/webapps'

        chef_run.node.set['cloudconductor']['applications'][app_name]['protocol'] = 'git'
        chef_run.node.set['cloudconductor']['applications'][app_name]['url'] = git_url
        chef_run.node.set['cloudconductor']['applications'][app_name]['revision'] = git_version
        chef_run.node.set['tomcat']['user'] = tomcat_user
        chef_run.node.set['tomcat']['group'] = tomcat_group
        chef_run.node.set['tomcat']['webapp_dir'] = tomcat_webapp_dir
        chef_run.converge(described_recipe)

        expect(chef_run).to deploy_deploy(app_name).with(
          repo: git_url,
          revision: git_version,
          deploy_to: tomcat_webapp_dir,
          user: tomcat_user,
          group: tomcat_group
        )
      end
    end
    describe 'application deploy protocol is http' do
      it 'application download from git' do
        url = 'http://cloudconductor.org/application.war'
        tomcat_user = 'tomcat'
        tomcat_group = 'passwd'
        tomcat_webapp_dir = '/var/lib/tomcat7/webapps'
        chef_run.node.set['cloudconductor']['applications'][app_name]['protocol'] = 'http'
        chef_run.node.set['cloudconductor']['applications'][app_name]['url'] = url
        chef_run.node.set['tomcat']['user'] = tomcat_user
        chef_run.node.set['tomcat']['group'] = tomcat_group
        chef_run.node.set['tomcat']['webapp_dir'] = tomcat_webapp_dir
        chef_run.converge(described_recipe)

        expect(chef_run).to create_remote_file(app_name).with(
          source: url,
          path: "#{tomcat_webapp_dir}/#{app_name}.war",
          mode: '0644',
          owner: tomcat_user,
          group: tomcat_group
        )
      end
    end

    it 'create context xml' do
      tomcat_user = 'tomcat'
      tomcat_group = 'passwd'
      context_dir = '/etc/tomcat7/Catalina/localhost'
      db_settings = {
        'type' => 'postgresql',
        'name' => 'application',
        'user' => 'application',
        'password' => 'pass',
        'host' => db_private_ip,
        'port' => 5432
      }
      data_source = 'jdbc/test'

      chef_run.node.set['tomcat']['user'] = tomcat_user
      chef_run.node.set['tomcat']['group'] = tomcat_group
      chef_run.node.set['tomcat']['context_dir'] = context_dir
      chef_run.node.set['tomcat_part']['database'] = db_settings
      chef_run.node.set['tomcat_part']['datasource'] = data_source
      chef_run.converge(described_recipe)

      expect(chef_run).to create_template("#{context_dir}/#{app_name}.xml").with(
        source: 'context.xml.erb',
        mode: '0644',
        owner: tomcat_user,
        group: tomcat_group,
        variables: {
          database: db_settings,
          datasource: data_source
        }
      )
    end
  end

  describe 'multiple dynamic type applications are included in "cloudconductor applications"' do
    app2_name = 'app2'
    before do
      chef_run.node.set['cloudconductor']['applications'] = {
        app_name => {
          type: 'dynamic'
        },
        app2_name => {
          type: 'dynamic'
        }
      }
      chef_run.converge(described_recipe)
    end
    it 'download of all applications' do
      chef_run.node.set['cloudconductor']['applications'][app_name]['protocol'] = 'git'
      chef_run.node.set['cloudconductor']['applications'][app2_name]['protocol'] = 'git'
      chef_run.converge(described_recipe)

      expect(chef_run).to deploy_deploy(app_name)
      expect(chef_run).to deploy_deploy(app2_name)
    end
    it 'create all applications context xml' do
      context_dir = '/etc/tomcat7/Catalina/localhost'
      chef_run.node.set['tomcat']['context_dir'] = context_dir
      chef_run.converge(described_recipe)

      expect(chef_run).to create_template("#{context_dir}/#{app_name}.xml")
      expect(chef_run).to create_template("#{context_dir}/#{app2_name}.xml")
    end
  end

  describe 'dynamic type applications as not included in "cloudconductor applications"' do
    before do
      chef_run.node.set['cloudconductor']['applications'] = {
        app_name => {
          type: 'statis'
        }
      }
      chef_run.converge(described_recipe)
    end
    it 'not download of applications' do
      chef_run.node.set['cloudconductor']['applications'][app_name]['protocol'] = 'git'
      chef_run.converge(described_recipe)

      expect(chef_run).to_not deploy_deploy(app_name)
    end
    it 'not create  context xml' do
      context_dir = '/etc/tomcat7/Catalina/localhost'
      chef_run.node.set['tomcat']['context_dir'] = context_dir
      chef_run.converge(described_recipe)

      expect(chef_run).to_not create_template("#{context_dir}/#{app_name}.xml")
    end
  end
end
