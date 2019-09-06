# Updater parameters
default['chef_client_manager']['updater']['interval'] = 60
default['chef_client_manager']['updater']['splay'] = 30
default['chef_client_manager']['updater']['airgapped'] = true
default['chef_client_manager']['updater']['force_cleanup'] = true

# Chef Client CLI parameters
default['chef_client_manager']['client']['cli']['interval'] = nil
default['chef_client_manager']['client']['cli']['splay'] = nil

# Chef Client client.rb settings
default['chef_client_manager']['client']['rb']['chef_server_url'] = Chef::Config['chef_server_url']
default['chef_client_manager']['client']['rb']['node_name'] = Chef::Config['node_name']
default['chef_client_manager']['client']['rb']['default_runlist'] = nil # or 'cookbook::recipe,cookbook::recipe'

# OS Specific parameters
case node['platform_family']
when 'windows'
  default['chef_client_manager']['desired']['package']['version'] = '14.6.47.1'
  default['chef_client_manager']['desired']['package']['url'] = 'https://packages.chef.io/files/stable/chef/14.6.47/windows/2016/chef-client-14.6.47-1-x64.msi'
  default['chef_client_manager']['desired']['package']['checksum'] = '5d20a33973472d64c40ff4642a94702c2c2205174f8178123199f40931d8d774'
when 'rhel'
  default['chef_client_manager']['desired']['package']['version'] = '14.6.47-1'
  default['chef_client_manager']['desired']['package']['url'] = 'https://packages.chef.io/files/stable/chef/14.6.47/el/7/chef-14.6.47-1.el7.x86_64.rpm'
  default['chef_client_manager']['desired']['package']['checksum'] = '95f6af95211a3ffae7db4c64302d4a78f6881cf4d1b4a72c3877fa6f149582c8'
else
  Chef::Log.fatal "#{cookbook_name} doesn't support #{node['platform_family']} yet"
end


# Latest versions from "https://packages.chef.io/api/v1/#{channel}/#{omnibus_project}/versions"
