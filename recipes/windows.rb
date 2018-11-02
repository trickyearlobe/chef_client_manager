#
# Cookbook:: chef_client_manager
# Recipe:: windows
#
# Copyright:: 2018, Richard Nixon
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
directory 'C:\ChefClientUpdater'
directory 'C:\ChefClientUpdater\PackageCache'

# The config file for the updater
file 'C:\ChefClientUpdater\config.json' do
  content JSON.pretty_generate(node['chef_client_manager'])
end

# The script which will run as a scheduled task
cookbook_file 'c:\ChefClientUpdater\ChefClientUpdater.ps1' do
  source 'ChefClientUpdater.ps1'
end

# Ensure we reliably get a scheduled task that runs the updater
# powershell_script and windows_task are not reliable in some Chef versions (particularly early 11.x versions)
cookbook_file 'c:\ChefClientUpdater\InstallChefClientUpdaterTask.ps1' do
  source 'InstallChefClientUpdaterTask.ps1'
end
execute "Chef Client Updater Scheduled Task" do
  command 'powershell.exe -ExecutionPolicy Unrestricted -Command c:\ChefClientUpdater\InstallChefClientUpdaterTask.ps1'
end