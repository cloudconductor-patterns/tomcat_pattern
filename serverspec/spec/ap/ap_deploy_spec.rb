require 'spec_helper'

describe 'application http status' do
  params = property[:consul_parameters]
  apps = params[:cloudconductor][:applications]

  apps.each do |app_name, app|
    next if app[:type] == 'optional'

    sleep 3

    describe "#{app_name}" do
      describe command("curl -s --noproxy localhost 'http://localhost:8080/#{app_name}' -w \"%{http_code}\" -o /dev/null") do
        its(:stdout) { should_not match '000' }
        its(:stdout) { should_not start_with '4' }
        its(:stdout) { should_not start_with '5' }
      end
    end
  end
end
