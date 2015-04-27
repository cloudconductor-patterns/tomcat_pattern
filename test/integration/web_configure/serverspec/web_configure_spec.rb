require 'spec_helper'
require 'json'

chef_run = ChefSpec::SoloRunner.new
chef_run.node.normal_attrs = property[:chef_attributes]
chef_run.converge('role[web_configure]')

describe service(chef_run.node['apache']['service_name']) do
  it { should be_running }
end

chef_run.node['apache']['listen_ports'].each do |listen_port|
  describe port(listen_port) do
    it { should be_listening.with('tcp') }
  end
end

ap_servers = chef_run.node['cloudconductor']['servers'].select { |_, s| s['roles'].include?('ap') }

describe file("#{chef_run.node['apache']['conf_dir']}/workers.properties") do
  it { should be_file }
  it { should be_mode 664 }
  it { should be_owned_by chef_run.node['apache']['user'] }
  it { should be_grouped_into chef_run.node['apache']['group'] }

  ap_servers.each do |hostname, server|
    it { should contain("worker.#{hostname}.reference=worker.template") }
    it { should contain("worker.#{hostname}.host=#{server['private_ip']}") }
    it { should contain("worker.#{hostname}.route=#{server['route']}") }
    it { should contain("worker.#{hostname}.lbfactor=#{server['weight']}") }
  end

  it { should contain("worker.loadbalancer.sticky_session=#{chef_run.node['apache_part']['sticky_session']}") }
end
