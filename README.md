# chef_client_version_manager (preview)

## Principles

* Upgrades/Downgrades must not rely on components of ChefClient/ChefDK (such as omnibus ruby.exe)
* Must work on chef-client 11+ since many customers still have v11
* Must work on Win2008R2 and above since we still support that platform
* Must be able to upgrade AND downgrade
* Must work in airgapped environments as a first class citizen

## Design Decisions

* Decouple the chef-client run and the upgrade process
  * Implement Windows upgrade process in PowerShell and run it as a Scheduled task
  * Use Chef to lay down the config file for the Windows upgrade process
  * Use Chef to ensure the client is configured to run periodically

* Powershell scripts must execute under PowerShell 4.0 and above to successfully run on Win2008R2
* Cannot use chef-client cookbook as its dependencies don't run under Chef Client 11 (which makes upgrading from 11 hard)
* Support retrieval of centralised out-of-band configuration to facilitate rollbacks (http get)
