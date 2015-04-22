require 'serverspec'
require 'chefspec'
require 'ohai'

set :backend, :exec

require 'consul_parameters'


pattern_root_dir = '/tmp/kitchen'

RSpec.configure do |c|
  if ENV['ASK_SUDO_PASSWORD']
    require 'highline/import'
    c.sudo_password = ask('Enter sudo password: ') { |q| q.echo = false }
  else
    c.sudo_password = ENV['SUDO_PASSWORD']
  end


  c.cookbook_path = File.join(pattern_root_dir, 'cookbooks')
  c.role_path = File.join(pattern_root_dir, 'roles')

  ohai = Ohai::System.new
  ohai.all_plugins('platform')

  c.platform = ohai[:platform]
  c.version = ohai[:platform_version]
end
