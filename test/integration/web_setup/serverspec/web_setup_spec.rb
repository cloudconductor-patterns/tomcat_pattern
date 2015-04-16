require 'spec_helper.rb'

describe package('httpd') do
  it { should be_installed }
end

describe service('httpd') do
  it { should be_enabled }
  it { should be_running }
end

describe package('httpd-devel') do
  it { should be_installed }
end

describe file('/usr/lib64/httpd/modules/mod_jk.so') do
  it { should be_file }
end

describe file('/etc/httpd/conf/workers.properties') do
  it { should be_file }
end

describe file('/etc/httpd/conf/uriworkermap.properties') do
  it { should be_file }
end

describe file('/etc/httpd/conf-available/mod-jk.conf') do
  it { should be_file }
  it { should be_mode 664 }
  it { should be_owned_by 'apache' }
  it { should be_grouped_into 'apache' }
end

describe file('/etc/httpd/conf-enabled/mod-jk.conf') do
  it { should be_file }
  it { should be_linked_to '/etc/httpd/conf-available/mod-jk.conf' }
end
