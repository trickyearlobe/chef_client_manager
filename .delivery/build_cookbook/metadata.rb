name 'build_cookbook'
maintainer 'Richard Nixon'
maintainer_email 'richard.nixon@btinternet.com'
license 'apachev2'
version '0.1.0'
chef_version '>= 12.1' if respond_to?(:chef_version)

depends 'delivery-truck'
