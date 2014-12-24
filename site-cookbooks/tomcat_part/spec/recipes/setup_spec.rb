require_relative '../spec_helper'

describe 'tomcat_part::setup' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  it 'create yum repository' do
    expect(chef_run).to ChefSpec::Matchers::ResourceMatcher.new(:yum_repository, :create, 'jpackage').with(
      description: 'JPackage 6 generic',
      mirrorlist: 'http://www.jpackage.org/mirrorlist.php?dist=generic&type=free&release=6.0',
      gpgcheck: false
    )
  end

  it 'include default recipe of tomcat cookbook' do
    expect(chef_run).to include_recipe('tomcat::default')
  end

  describe 'using database is mysql' do
    it 'download mysql dirver file' do
      chef_run.node.set['tomcat_part']['database']['type'] = 'mysql'
      chef_run.node.set['tomcat_part']['jdbc']['mysql'] = 'http://example.com/mysql_driver.jar'
      chef_run.node.set['tomcat_part']['jdbc']['postgresql'] = 'http://example.com/postgresql_driver.jar'
      chef_run.node.set['tomcat_part']['jdbc']['oracle'] = 'http://example.com/oracle_driver.jar'
      chef_run.converge(described_recipe)

      expect(chef_run).to create_remote_file('/usr/share/tomcat7/lib/mysql_driver.jar').with(
        source: 'http://example.com/mysql_driver.jar'
      )
    end
  end

  describe 'using database is postgresql' do
    it 'download mysql dirver file' do
      chef_run.node.set['tomcat_part']['database']['type'] = 'postgresql'
      chef_run.node.set['tomcat_part']['jdbc']['mysql'] = 'http://example.com/mysql_driver.jar'
      chef_run.node.set['tomcat_part']['jdbc']['postgresql'] = 'http://example.com/postgresql_driver.jar'
      chef_run.node.set['tomcat_part']['jdbc']['oracle'] = 'http://example.com/oracle_driver.jar'
      chef_run.converge(described_recipe)

      expect(chef_run).to create_remote_file('/usr/share/tomcat7/lib/postgresql_driver.jar').with(
        source: 'http://example.com/postgresql_driver.jar'
      )
    end
  end

  describe 'using database is oracle' do
    it 'download mysql dirver file' do
      chef_run.node.set['tomcat_part']['database']['type'] = 'oracle'
      chef_run.node.set['tomcat_part']['jdbc']['mysql'] = 'http://example.com/mysql_driver.jar'
      chef_run.node.set['tomcat_part']['jdbc']['postgresql'] = 'http://example.com/postgresql_driver.jar'
      chef_run.node.set['tomcat_part']['jdbc']['oracle'] = 'http://example.com/oracle_driver.jar'
      chef_run.converge(described_recipe)

      expect(chef_run).to create_remote_file('/usr/share/tomcat7/lib/oracle_driver.jar').with(
        source: 'http://example.com/oracle_driver.jar'
      )
    end
  end

  describe 'driver archive file is tar.gz' do
    before do
      chef_run.node.set['tomcat_part']['database']['type'] = 'mysql'
      chef_run.node.set['tomcat_part']['jdbc']['mysql'] = 'http://example.com/driver.tar.gz'
      chef_run.converge(described_recipe)
    end

    it 'download driver archive file' do
      expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/driver.tar.gz").with(
        source: 'http://example.com/driver.tar.gz'
      )
    end

    it 'extract driver from driver archive' do
      expect(chef_run).to run_bash('extract_jdbc_driver')
    end
  end

  describe 'driver archive file is not tar.gz' do
    it 'download dirver file' do
      chef_run.node.set['tomcat_part']['database']['type'] = 'postgresql'
      chef_run.node.set['tomcat_part']['jdbc']['postgresql'] = 'http://example.com/driver.jar'
      chef_run.converge(described_recipe)

      expect(chef_run.node['tomcat']['home']).to eq('/usr/share/tomcat7')

      expect(chef_run).to create_remote_file('/usr/share/tomcat7/lib/driver.jar').with(
        source: 'http://example.com/driver.jar'
      )
    end
  end

  it 'chown tomcat home' do
    expect(chef_run.node['tomcat']['user']).to eq('tomcat')
    expect(chef_run.node['tomcat']['group']).to eq('tomcat')
    expect(chef_run.node['tomcat']['home']).to eq('/usr/share/tomcat7')

    expect(chef_run).to run_bash('chown_tomcat_home').with(
      code: 'chown tomcat:tomcat /usr/share/tomcat7'
    )
  end
end
