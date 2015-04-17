require 'spec_helper'

describe service('httpd') do
  it { should be_running }
end

describe port(80) do
  it { should be_listening.with('tcp') }
end

# ToDo Change to attribute value get from Consul
describe file('/etc/httpd/conf/uriworkermap.properties') do
  it { should be_file }
  it { should be_mode 664 }
  it { should be_owned_by 'apache' }
  it { should be_grouped_into 'apache' }
  it { should contain('/jpetstore=loadbalancer') }
  it { should contain('/jpetstore/*=loadbalancer') }
end
