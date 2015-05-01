require 'serverspec'
require 'chefspec'
require 'ohai'
require 'consul_parameters'
require 'active_support'

set :backend, :exec

if Dir.pwd == '/tmp/busser/suites/rspec'
  pattern_root_dir = '/tmp/kitchen'
  kitchen_attributes = open(File.join(pattern_root_dir, 'dna.json')) do |io|
    JSON.load(io)
  end
  properties = { chef_attributes: kitchen_attributes }
else
  pattern_root_dir = File.expand_path('../../../../', File.dirname(__FILE__))

  include ConsulParameters
  parameters = read_parameters
  parameters[:cloudconductor][:servers] = read_servers
  if parameters[:cloudconductor][:patterns][:tomcat_pattern][:user_attributes]
    parameters.deep_merge!(parameters[:cloudconductor][:patterns][:tomcat_pattern][:user_attributes])
  end
  properties = { chef_attributes: parameters }
end

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
