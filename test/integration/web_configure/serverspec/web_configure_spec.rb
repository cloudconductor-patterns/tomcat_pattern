require 'spec_helper.rb'

describe service('httpd') do
  it { should be_running }
end

describe port(80) do
  it { should be_listening.with('tcp') }
end
