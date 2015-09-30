require 'spec_helper'
require 'json'

describe 'web_setup' do
  chef_run = ChefSpec::SoloRunner.new

  before(:all) do
    stub_command('/usr/sbin/httpd -t').and_return(0)
    chef_run.node.normal_attrs = property[:chef_attributes]
    chef_run.converge('role[web_setup]')
  end

  it 'is installed apache package' do
    expect(package(chef_run.node['apache']['package'])).to be_installed
  end

  it 'is s apache service enabled and running' do
    expect(service(chef_run.node['apache']['service_name'])).to be_enabled.and be_running
  end

  it 'is installed apache devel package' do
    expect(package("#{chef_run.node['apache']['package']}-devel")).to be_installed
  end

  it 'is exist a mod_jk.so file' do
    expect(file("#{chef_run.node['apache']['libexec_dir']}/mod_jk.so")).to be_file
  end

  it 'is exist a workers.properties file' do
    expect(file("#{chef_run.node['apache']['conf_dir']}/workers.properties")).to be_file
  end

  it 'is exist a uriworkermap.properties file' do
    expect(file("#{chef_run.node['apache']['conf_dir']}/uriworkermap.properties")).to be_file
  end

  it 'is mod-jk.conf file set given mode, owned by a given user, grouped in to a given group, and exist' do
    expect(file("#{chef_run.node['apache']['dir']}/conf-available/mod-jk.conf"))
      .to be_file.and be_mode(664).and be_owned_by('apache').and be_grouped_into('apache')
  end

  it 'is conf-enabled/mod-jk.conf are linked to conf-available/mod-jk.conf' do
    expect(file("#{chef_run.node['apache']['dir']}/conf-enabled/mod-jk.conf"))
      .to be_linked_to "#{chef_run.node['apache']['dir']}/conf-available/mod-jk.conf"
  end
end
