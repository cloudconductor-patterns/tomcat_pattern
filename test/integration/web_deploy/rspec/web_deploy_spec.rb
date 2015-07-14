require 'spec_helper'
require 'json'

describe 'web_deploy' do
  chef_run = ChefSpec::SoloRunner.new

  before(:all) do
    chef_run.node.normal_attrs = property[:chef_attributes]
    chef_run.converge('role[web_deploy]')
  end

  it do
    expect(service(chef_run.node['apache']['service_name'])).to be_running
  end

  it do
    chef_run.node['apache']['listen_ports'].each do |listen_port|
      expect(port(listen_port)).to be_listening.with('tcp')
    end
  end

  it do
    expect(file("#{chef_run.node['apache']['conf_dir']}/uriworkermap.properties"))
      .to be_file
      .and be_mode(664)
      .and be_owned_by(chef_run.node['apache']['user'])
      .and be_grouped_into(chef_run.node['apache']['group'])
  end

  it do
    chef_run.node['cloudconductor']['applications'].keys.each do |key|
      expect(file("#{chef_run.node['apache']['conf_dir']}/uriworkermap.properties"))
        .to contain("/#{key}=loadbalancer")
        .and contain("/#{key}/*=loadbalancer")
    end
  end
end
