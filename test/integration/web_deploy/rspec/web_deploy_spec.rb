require 'spec_helper'
require 'json'

describe 'web_deploy' do
  chef_run = ChefSpec::SoloRunner.new

  before(:all) do
    chef_run.node.normal_attrs = property[:chef_attributes]
    chef_run.converge('role[web_deploy]')
  end

  it 'apache service is running' do
    expect(service(chef_run.node['apache']['service_name'])).to be_running
  end

  it 'apache service listening port is tcp' do
    chef_run.node['apache']['listen_ports'].each do |listen_port|
      expect(port(listen_port)).to be_listening # .with('tcp') # ipv4 or ipv5
    end
  end

  it 'apache configuration file is exists' do
    expect(file("#{chef_run.node['apache']['conf_dir']}/uriworkermap.properties"))
      .to be_file
      .and be_mode(664)
      .and be_owned_by(chef_run.node['apache']['user'])
      .and be_grouped_into(chef_run.node['apache']['group'])
  end

  it 'loadbalancer config is found into apache configuration file' do
    chef_run.node['cloudconductor']['applications'].keys.each do |key|
      expect(file("#{chef_run.node['apache']['conf_dir']}/uriworkermap.properties"))
        .to contain("/#{key}=loadbalancer")
        .and contain("/#{key}/*=loadbalancer")
    end
  end
end
