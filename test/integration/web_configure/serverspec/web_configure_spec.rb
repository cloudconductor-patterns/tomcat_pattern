require 'spec_helper.rb'

describe service('httpd') do
  it { should be_running }
end

describe port(80) do
  it { should be_listening.with('tcp') }
end

describe file('/etc/httpd/conf/workers.properties') do
  it { should be_mode 664 }
  it { should be_owned_by 'apache' }
  it { should be_grouped_into 'apache' }
  it { should contain('worker.loadbalancer.sticky_session=true') }
  it { should contain('worker.ap_01.reference=worker.template') }
  it { should contain('worker.ap_01.host=127.0.0.1') }
  it { should contain('worker.ap_01.route=127.0.0.1') }
  it { should contain('worker.ap_01.lbfactor=0') }
end
