require 'spec_helper'
require 'json'

describe 'web_configure' do
  chef_run = ChefSpec::SoloRunner.new

  before(:all) do
    chef_run.node.normal_attrs = property[:chef_attributes]
    chef_run.converge('role[web_configure]')
  end

  it 'is apache service is running ' do
    expect(service(chef_run.node['apache']['service_name'])).to be_running
  end

  it 'is apache ports is listning' do
    chef_run.node['apache']['listen_ports'].each do |listen_port|
      expect(port(listen_port)).to be_listening.with('tcp')
    end
  end

  it 'is workers.properties file set given mode, owned by a given user, grouped in to a given group, and exist'do
    expect(file("#{chef_run.node['apache']['conf_dir']}/workers.properties"))
      .to be_file
      .and be_mode(664)
      .and be_owned_by(chef_run.node['apache']['user'])
      .and be_grouped_into(chef_run.node['apache']['group'])
  end

  it 'is workers.properties file contains the all ap server settings' do
    ap_servers = chef_run.node['cloudconductor']['servers'].select { |_, s| s['roles'].include?('ap') }
    ap_servers.each do |hostname, server|
      expect(file("#{chef_run.node['apache']['conf_dir']}/workers.properties"))
        .to contain("worker.#{hostname}.reference=worker.template")
        .and contain("worker.#{hostname}.host=#{server['private_ip']}")
        .and contain("worker.#{hostname}.route=#{server['route']}")
        .and contain("worker.#{hostname}.lbfactor=#{server['weight']}")
    end
  end
end
