require 'serverspec'
require 'chefspec'
require 'ohai'

set :backend, :exec

require 'consul_parameters'


pattern_root_dir = '/tmp/kitchen'

kitchen_attributes = open('/tmp/kitchen/dna.json') do |io|
  JSON.load(io)
end

properties = { chef_attributes: kitchen_attributes }

set_property properties

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
