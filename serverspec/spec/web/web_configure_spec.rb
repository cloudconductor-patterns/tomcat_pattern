require 'spec_helper.rb'

# Check Service status

describe service('httpd') do
  it { should be_running }
end

# Cehck listen port
describe port(80) do
  it { should be_listening.with('tcp') }
end
