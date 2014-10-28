require_relative '../spec_helper'

describe 'tomcat_part::setup' do
  let(:chef_postgresql_run) do
    ChefSpec::SoloRunner.new(
      cookbook_path: ['cookbooks', 'site-cookbooks'],
      platform: 'centos',
      version: '6.5'
    ) do |node|
      node.set['tomcat_part']['database']['type'] = 'postgresql'
      node.set['tomcat_part']['jdbc']['postgresql'] = 'http://jdbc.postgresql.org/download/postgresql-9.3-1102.jdbc41.jar'
      node.set['tomcat']['home'] = '/usr/share/tomcat7'
      node.set['tomcat']['user'] = 'tomcat'
      node.set['tomcat']['group'] = 'tomcat'
    end.converge(described_recipe)
  end
  let(:chef_mysql_run) do
    ChefSpec::SoloRunner.new(
      cookbook_path: ['cookbooks', 'site-cookbooks'],
      platform: 'centos',
      version: '6.5'
    ) do |node|
      node.set['tomcat_part']['database']['type'] = 'mysql'
      node.set['tomcat_part']['jdbc']['mysql'] = 'http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.33.tar.gz'
      node.set['tomcat']['home'] = '/usr/share/tomcat7'
      node.set['tomcat']['user'] = 'tomcat'
      node.set['tomcat']['group'] = 'tomcat'
    end.converge(described_recipe)
  end

  it 'yum_repository install for jpackage' do
    ChefSpec::Matchers::ResourceMatcher.new(:yum_repository, :create, 'jpackage').with(
      description: 'JPackage 6 generic',
      mirrorlist: 'http://www.jpackage.org/mirrorlist.php?dist=generic&type=free&release=6.0',
      gpgcheck: 'false'
    )
  end

  it 'includes `tomcat` recipe' do
    expect(chef_postgresql_run).to include_recipe('tomcat')
  end

  it 'does not include `not_tomcat` recipe' do
    expect(chef_postgresql_run).to_not include_recipe('not_tomcat')
  end

  it 'jdbc driver install in tarball files' do
    expect(chef_mysql_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/mysql-connector-java-5.1.33.tar.gz").with(
      source: 'http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.33.tar.gz'
    )
    expect(chef_mysql_run).to_not \
    create_remote_file("#{Chef::Config[:file_cache_path]}/not-mysql-connector-java-5.1.33.tar.gz").with(
      source: 'http://dev.mysql.com/get/Downloads/Connector-J/not-mysql-connector-java-5.1.33.tar.gz'
    )
  end

  it 'extractr jdbc driver' do
    expect(chef_mysql_run).to run_bash('extract_jdbc_driver').with(
      code: "tar -zxvf #{Chef::Config[:file_cache_path]}/mysql-connector-java-5.1.33.tar.gz -C /usr/share/tomcat7/lib"
    )
  end

  it 'jdbc driver install in jar files' do
    expect(chef_postgresql_run).to create_remote_file('/usr/share/tomcat7/lib/postgresql-9.3-1102.jdbc41.jar').with(
      source: 'http://jdbc.postgresql.org/download/postgresql-9.3-1102.jdbc41.jar'
    )
    expect(chef_postgresql_run).to_not create_remote_file('/usr/share/tomcat7/lib/not-postgresql-9.3-1102.jdbc41.jar').with(
      source: 'http://jdbc.postgresql.org/download/not-postgresql-9.3-1102.jdbc41.jar'
    )
  end

  it 'chown tomcat home' do
    expect(chef_postgresql_run).to run_bash('chown_tomcat_home').with(
      code: 'chown tomcat:tomcat /usr/share/tomcat7'
    )
    expect(chef_postgresql_run).to_not run_bash('not_chown_tomcat_home').with(
      code: 'chown foo:bar /usr/share/tomcat7'
    )
  end
end
