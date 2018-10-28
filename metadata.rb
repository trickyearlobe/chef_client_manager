name 'chef_client_version_manager'
maintainer 'Richard Nixon'
maintainer_email 'richard.nixon@btinternet.com'
license 'Apache-2.0'
description 'Installs/Configures chef_client_version_manager'
long_description 'Installs/Configures chef_client_version_manager'
version '0.1.0'
chef_version '>= 12.1' if respond_to?(:chef_version)

# Older Chef Clients dont support issues_url and source_url so make them conditional
issues_url 'https://github.com/trickyearlobe/chef_client_version_manager/issues' if respond_to?(:issues_url)
source_url 'https://github.com/trickyearlobe/chef_client_version_manager' if respond_to?(:source_url)
