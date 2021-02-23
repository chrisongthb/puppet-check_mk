# check_mk

<!-- vscode-markdown-toc -->
* 1. [Description](#Description)
* 2. [Getting Started](#GettingStarted)
	* 2.1. [Server](#Server)
	* 2.2. [Agent](#Agent)
* 3. [Further Configuration](#FurtherConfiguration)
	* 3.1. [Server](#Server-1)
	* 3.2. [Agent](#Agent-1)
		* 3.2.1. [Encryption](#Encryption)
		* 3.2.2. [Defaults for library items and configuration items](#Defaultsforlibraryitemsandconfigurationitems)
		* 3.2.3. [Plugins (library item)](#Pluginslibraryitem)
		* 3.2.4. [Plugin Configs (configuration item)](#PluginConfigsconfigurationitem)
		* 3.2.5. [Local Checks (library item)](#LocalCheckslibraryitem)
		* 3.2.6. [Logwatch](#Logwatch)
		* 3.2.7. [Other](#Other)
* 4. [Limitations](#Limitations)
* 5. [Development](#Development)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->


##  1. <a name='Description'></a>Description

This module manages Check_mk agent and partly Check_mk server. It mainly provides an alternative to Check_mk agent bakery as configuration items (e.g. `/etc/check_mk/…`) and library items (e.g. `/usr/lib/check_mk_agent/…`) can be fully managed with Puppet. This is a very comfortable way of automating your check_mk agents in Puppet centralized environments, as you have now all benefits of standardization and vcs on check_mk.

In contrast to the agent, the server part is widely untouched. Check_mk server installations (and upgrades!) need a human not to mess up the whole thing. Hence, the module only lets you manage the htpasswd file for each site and lets you install required packages. Further more it provides a fact `omdsites`, which you can use in your profiles for more specific adoptions (such as managing the site-apache for SSO, etc.)

##  2. <a name='GettingStarted'></a>Getting Started

There is no main class (reg. init.pp). Please see server and agent parts.  
*Note:* A node can contain the cmk server and cmk agent part at once.

###  2.1. <a name='Server'></a>Server
Start by typing
```puppet
contain check_mk::server
```
Puppet will then install required packages. Inspect module hiera data or overwrite the param on your own.


###  2.2. <a name='Agent'></a>Agent
The installation of the agent requires the package either to be located in a repo or to be available on the node. For an installation from source you have to configure `check_mk::client::package_provider` and `check_mk::client::package_source`.

*Note:* This module does not handle the package file management as there are too many options to implement that. It highly depends on your environment how you want to install the check_mk_agent package.

If you provide the agent package on an already included repo, start by typing
```puppet
contain check_mk::agent
```
Puppet will then install the agent and create the library item directory and the config item directory. Inspect module hiera data for directory names.

*Note:* Puppet will purge all not managed files in these directories.

##  3. <a name='FurtherConfiguration'></a>Further Configuration

###  3.1. <a name='Server-1'></a>Server
This module does not create OMD sites and does not configure them, as it may be very dangerous if you do it automated. Thus, please exec the omd commands manually.

To manage local htpasswd users per site you have to provide a hash for `check_mk::server::htpasswd_users`. Example:

`common.yaml`
```yaml
---
check_mk::server::htpasswd_users:
  '*': # defaults for all Check_mk servers and all sites on them
    adminuser: '$1$451319$dlsdfjghlkjsfngkjnj45n63456'
    automation: '$1$451319$dlsdfgjsdfhgkjherjtgdfg'
```

`cmkserver.my.domain.yaml`
```yaml
---
check_mk::server::htpasswd_users:
  'main': # only for site main on cmkserver.my.domain
    extrauserone: '$1$453419$d3567889dfjkfdgh895435'
    extrausertwo: '$1$453419$d39dfj59789g9d8f7gsdfg'
  'integration': # only for site integration on cmkserver.my.domain
    extrauserone: '$1$453419$d3567889dfjkfdgh895435'
    extrausertwo: '$1$453419$d39dfj59789g9d8f7gsdfg'
```
[Inspect the hiera docs on how to merge this data](https://puppet.com/docs/puppet/latest/hiera_merging.html). Then you will have the adminuser and automation user in addition to the site users.

*Note:* You can use the `omdsites` fact in your profiles to automate site configs on your own (e.g. apache SSO, etc.).

###  3.2. <a name='Agent-1'></a>Agent

Please see Reference for all params.

####  3.2.1. <a name='Encryption'></a>Encryption

To enable encryption:
```yaml
---
check_mk::client::encryption_passphrase: >
  ENC[PKCS7, kdjfvkuwezriusdfhudf879845u6ojhgkhdfg987598ukdjsgh98w7e56…]
```

####  3.2.2. <a name='Defaultsforlibraryitemsandconfigurationitems'></a>Defaults for library items and configuration items

Optional: It is useful (and recommended!) to provide the default locations for configuration EPPs and library items. For example, this extra repo could be your control-repo.
```yaml
---
check_mk::client::library_item_default_file_source_path: 'puppet:///modules/<my_extra_repo>/check_mk/client/'
check_mk::client::configuration_item_default_epp_path: '<my_extra_repo>/check_mk/client/'
```
If you don't want to use EPPs and file source deployment for library items, you can provide a string (the content) for each file (see below).

####  3.2.3. <a name='Pluginslibraryitem'></a>Plugins (library item)

This example requires the library items in your file store (see above). One could provide the plugin file contents as plain text here as well. Please see Reference for detailled information.

```yaml
---
check_mk::client::plugins:
  mk_inventory.linux:
  mk_apt:
  mk_logwatch:
  my_own_plugin:
    exec_interval: 3600
    required_packages:
      - 'python3-fancy'
      - 'python3-wow'
```

[Inspect the hiera docs on how to merge data](https://puppet.com/docs/puppet/latest/hiera_merging.html) and how to extend the baseline of plugins from common.yaml in node.yamls.


####  3.2.4. <a name='PluginConfigsconfigurationitem'></a>Plugin Configs (configuration item)

This example requires a valid epp for apache_status in you default epp store (see above). Instead of giving a hash, one could provide the config file contents as plain text here as well. Please see Reference for detailled information.

```yaml
---
check_mk::client::plugin_configs:
  apache_status:
    localhost_80:
      protocol: 'http'
      host: 'localhost'
      port: 80
    localhost_443:
      protocol: 'https'
      host: 'localhost'
      port: 443
```

####  3.2.5. <a name='LocalCheckslibraryitem'></a>Local Checks (library item)

This example requires these library items in your file store (see above). One could provide the check file contents as plain text here as well. Please see Reference for detailled information.

```yaml
---
check_mk::client::local_checks:
  my_plugin:
    required_packages:
      - "nmon"
    exec_interval: 3600
    content: "#!/bin/bash\necho new line is working!\n"
  check_locale:
  check_foo:
```

####  3.2.6. <a name='Logwatch'></a>Logwatch

One could provide a baseline config in common.yaml…
```yaml
---
check_mk::client::logwatch_entries:
  '/var/log/syslog':
    - 'C .*I/O error.*'
    - 'C .* segfault at .*'
```

… and extend it in specific yamls:
```yaml
---
check_mk::client::logwatch_entries:
  '/var/log/java-app.log':
    - 'W This is a Warning:.*'
    - 'C java\.lang\.OutOfMemoryError:.*'
```

[Inspect the hiera docs on how to merge this data](https://puppet.com/docs/puppet/latest/hiera_merging.html).

####  3.2.7. <a name='Other'></a>Other

One could also deploy library items and configuration items directly per Puppet DSL…
```ruby
::check_mk::client::configuration_item { 'extra_config':
  mode   => '0400',
  config => 'my content',
}
```
```ruby
::check_mk::client::library_item { 'extra_lib':
  library_path => 'plugins',
  content      => 'my content',
```

… Or in hiera:
```yaml
---
check_mk::client::configuration_items:
  extra_config_one:
    mode: '0400'
    config: |
      my
      super
      config
  extra_config_two:
    mode: '0400'
    config: |
      another
      super
      config
```
```yaml
---
check_mk::client::library_items:
  extra_lib:
    library_path: 'plugins'
    content: |
      #!/bin/bash
      echo 'my plugin'

```


##  4. <a name='Limitations'></a>Limitations

* Does not manage xinetd oder systemd socket. There are extra modules for that purpose, see [here](https://forge.puppet.com/puppetlabs/xinetd) and [here](https://forge.puppet.com/camptocamp/systemd)
* Does not install or configure omd packages or omd sites. See above.
* The Agent part is verified on Ubuntu >= 14.04 and CentOS 7
* The Server part is verified on Ubuntu >= 18.04
* It should work on all Debian based and RedHat based distros :smile:

##  5. <a name='Development'></a>Development

Any contributing is welcome!
Please [open a issue](https://github.com/chrisongthb/puppet-check_mk/issues) or [create a pull request](https://github.com/chrisongthb/puppet-check_mk/compare) on Github.
