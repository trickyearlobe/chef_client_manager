name 'chef_client_manager'
maintainer 'Richard Nixon'
maintainer_email 'richard.nixon@btinternet.com'
license 'Apache-2.0'
description 'Configures and upgrades Chef Client'
long_description 'Alternative to chef_client_updater and chef-client cookbooks'
version '0.1.0'

# Older Chef Clients dont support these metadata items so make them conditional
chef_version '>= 12.1' if respond_to?(:chef_version)
issues_url   'https://github.com/trickyearlobe/chef_client_manager/issues' if respond_to?(:issues_url)
source_url   'https://github.com/trickyearlobe/chef_client_manager' if respond_to?(:source_url)
