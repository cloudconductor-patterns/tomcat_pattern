# -*- coding: utf-8 -*-
# Copyright 2014 TIS Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'chef/recipe'
require 'chef/resource'
require 'chef/provider'

require 'cloud_conductor_utils/consul'

module CloudConductor
  module Helper
    def generate_random(key = '', size = 16)
      seed = node[:cloudconductor][:seed].to_i
      key_hash = key.each_byte.inject(0) { |a, e| a * 256 + e }
      before_seed = srand(seed + key_hash)

      result = size.times.map { rand(256).to_s(16).rjust(2, '0') }.join

      srand(before_seed)
      result
    end

    def server_info(role)
      all_servers = CloudConductorUtils::Consul.read_servers
      servers = all_servers.select do |_hostname, server|
        server[:roles].include?(role)
      end
      result = servers.map do |hostname, server|
        server[:hostname] = hostname
        server
      end
      result
    end
  end
end

Chef::Recipe.send(:include, CloudConductor::Helper)
Chef::Resource.send(:include, CloudConductor::Helper)
Chef::Provider.send(:include, CloudConductor::Helper)
