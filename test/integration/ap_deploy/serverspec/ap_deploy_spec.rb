require 'spec_helper'

describe 'jpetstore' do
  describe command("curl -s --noproxy localhost 'http://localhost:8080/jpetstore/' -w \"%{http_code}\" -o /dev/null") do
    its(:stdout) { should_not match '000' }
    its(:stdout) { should_not start_with '4' }
    its(:stdout) { should_not start_with '5' }
  end
end
