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
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'foodcritic'

# Rspec and ChefSpec
desc 'Run Rspec examples'
RSpec::Core::RakeTask.new(:rspec)

desc 'Run ChefSpec examples'
RSpec::Core::RakeTask.new(:chefspec) do |t|
  t.pattern = 'site-cookbooks/**/*_spec.rb'
  t.verbose = false
end

# Style tests, rubocop and Rubocop and FoodCritic
namespace :style do
  desc 'Run Ruby style checks'
  RuboCop::RakeTask.new(:ruby)

  desc 'Run Chef style checks'
    FoodCritic::Rake::LintTask.new(:chef) do |t|
      t.options = {
        cookbook_paths: ['site-cookbooks']
      }
  end
end

desc 'Run all style checks'
task style:['style:ruby', 'style:chef']

task defauls: ['style', 'rspec', 'chefspec']
