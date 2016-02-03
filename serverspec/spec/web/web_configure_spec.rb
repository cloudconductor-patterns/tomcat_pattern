require 'spec_helper.rb'

# Check Service status

describe service('httpd') do
  it { should be_running }
end

# Cehck listen port
describe port(80) do
  it { should be_listening } # ipv4 or ipv6
end

# Check connect ap servers
describe 'connect ap_servers' do
  ap_servers = property[:servers].each_value.select do |server|
    server[:roles].include?('ap')
  end

  ap_servers.each do |server|
    describe command("hping3 -S #{server[:private_ip]} -p 8009 -c 5") do
      its(:stdout) { should match(/sport=8009 flags=SA/) }
    end
  end
end
