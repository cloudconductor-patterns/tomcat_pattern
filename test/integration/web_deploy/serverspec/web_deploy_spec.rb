require 'spec_helper'

chef = ChefSpec::SoloRunner.new
chef.node.set['cloudconductor']['applications'] = {
  'application' => {}
}
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
  it { should contain('/jpetstore=loadbalancer') }
  it { should contain('/jpetstore/*=loadbalancer') }
end
