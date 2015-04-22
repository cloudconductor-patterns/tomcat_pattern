require 'spec_helper'

require 'json'

kitchen_attributes = open('/tmp/kitchen/dna.json') do |io|
  JSON.load(io)
end

chef = ChefSpec::SoloRunner.new

chef.node.normal_attrs = kitchen_attributes

chef.converge('role[web_deploy]')

describe service(chef.node['apache']['service_name']) do
  it { should be_running }
end

chef.node['apache']['listen_ports'].each do |listen_port|
  describe port(listen_port) do
    it { should be_listening.with('tcp') }
  end
end

describe file("#{chef.node['apache']['conf_dir']}/uriworkermap.properties") do
  it { should be_file }
  it { should be_mode 664 }
  it { should be_owned_by chef.node['apache']['user'] }
  it { should be_grouped_into chef.node['apache']['group'] }
  chef.node['cloudconductor']['applications'].keys.each do |key|
    it { should contain("/#{key}=loadbalancer") }
    it { should contain("/#{key}/*=loadbalancer") }
  end
end
