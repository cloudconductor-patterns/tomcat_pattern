require 'spec_helper'

describe service('tomcat') do
  it { should be_running }
end

describe port(8009) do
  it { should be_listening.with('tcp') }
end
