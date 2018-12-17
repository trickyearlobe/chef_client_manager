#
# Cookbook:: chef_client_manager
# Recipe:: windows
#
# Copyright:: 2018, Lukasz Kasprzak
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

Chef::Log.info "Executing #{cookbook_name}::#{recipe_name}"

# Keep updater stuff together
directory '/opt/ChefClientUpdater'
directory '/opt/ChefClientUpdater/PackageCache'

# The config file for the updater
file '/opt/ChefClientUpdater/config.json' do
  content JSON.pretty_generate(node['chef_client_manager'])
end

cookbook_file '/opt/ChefClientUpdater/ChefClientUpdater.sh' do
  source 'ChefClientUpdater.sh'
  mode '0755'
end

#cron_d resource is available from chef-client 14.4
if Gem::Requirement.new('<= 14.4.0').satisfied_by?(Gem::Version.new(Chef::VERSION))
  cron 'ChefClientUpdater' do
    minute  "*/15"
    command '/opt/ChefClientUpdater/ChefClientUpdater.sh'
  end
else
  cron_d 'ChefClientUpdater' do
    minute  "*/15"
    command '/opt/ChefClientUpdater/ChefClientUpdater.sh'
  end
end
