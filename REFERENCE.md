# Reference

<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

### Classes

#### Public Classes

* [`check_mk`](#check_mk): Empty class, do not include. See check_mk::client or check_mk::server
* [`check_mk::client`](#check_mkclient): Installs and configures check_mk agent
* [`check_mk::server`](#check_mkserver): Configures Check_mk server

#### Private Classes

* `check_mk::client::config`: This class is called from check_mk::client to configure base things
* `check_mk::client::install`: This class is called from check_mk::client to install the agent
* `check_mk::server::config`: This class is called from check_mk::server to configure server things.
* `check_mk::server::install`: This class is called from check_mk::server for installation of required packages.

### Defined types

* [`check_mk::client::configuration_item`](#check_mkclientconfiguration_item): Deploys one configuration file
* [`check_mk::client::library_item`](#check_mkclientlibrary_item): deploys one library_item file, that is e.g. a plugin or a local check

## Classes

### `check_mk`

Empty class, do not include. See check_mk::client or check_mk::server

### `check_mk::client`

Library- and Configuration- items are indented for those, who don't want or can't use the agent bakery
Not managed Library- and Configuration- items will be deleted!

#### Examples

##### 

```puppet
include check_mk::client
```

#### Parameters

The following parameters are available in the `check_mk::client` class.

##### `package_name`

Data type: `String[1]`

The name of the Check_mk agent package

##### `package_ensure`

Data type: `String[1]`

The `ensure` value to use when installing the agent. This option can be used to install a specific package version.

##### `configuration_item_path`

Data type: `Stdlib::Absolutepath`

The Check_mk agent base configuration directory (e.g. `/etc/check_mk`)

##### `configuration_item_default_mode`

Data type: `String[1]`

The default file mode for Check_mk agent configuration files. Can be overwritten per configuration_item

##### `library_item_path`

Data type: `Stdlib::Absolutepath`

The base path of plugins, local checks (e.g. `/usr/lib/check_mk_agent`)

##### `library_item_default_mode`

Data type: `String[1]`

The default file mode for Check_mk agent configuration files. Can be overwritten per library_item.

##### `library_item_default_exec_interval`

Data type: `Optional[Integer[0]]`

The default interval of plugins and local checks. This can be used to configure caching for explicit libs.

Default value: ``undef``

##### `library_item_default_file_source_path`

Data type: `Optional[String[1]]`

Where to find the sources of library items rolled out by `source` (and not by content). You can configure you own file storage here (could be an extra repo with special permissions for monitoring admins…)

Default value: ``undef``

##### `encryption_passphrase`

Data type: `Optional[String[1]]`

Wraps an instance of configuration_item and defines the encryption secret for the check_mk_agent.

Default value: ``undef``

##### `logwatch_entries`

Data type: `Optional[Hash[String[1],Array[String[1]]]]`

Wraps an instance of configuration_item and defines logwatch entries for the check_mk_agent.

Default value: ``undef``

##### `plugin_configs`

Data type: `Optional[Hash[String[1],Hash]]`

Is a hash and wraps instances of configuration_item to provide a speaking name for monitoring admins. For examples see README.md

Default value: ``undef``

##### `configuration_items`

Data type: `Optional[Hash]`

Is a hash and installes files in configuration_item_path (e.g. `/etc/check_mk/mrpe.cfg`). For examples see README.md

Default value: ``undef``

##### `configuration_item_default_epp_path`

Data type: `Optional[String[1]]`

Where to find epp templates, when the $config of a configuration_item is a hash. For examples see README.md

Default value: ``undef``

##### `plugins`

Data type: `Optional[Hash[String[1],Optional[Hash[String[1],NotUndef]]]]`

Is a hash and wraps instances of library_item to provide a speaking name for monitoring admins. For examples see README.md

Default value: ``undef``

##### `local_checks`

Data type: `Optional[Hash[String[1],Optional[Hash[String[1],NotUndef]]]]`

Is a hash and wraps instances of library_item to provide a speaking name for monitoring admins. For examples see README.md

Default value: ``undef``

##### `library_items`

Data type: `Optional[Hash]`

Is a hash and installes files in library_item_path (e.g. `/usr/lib/check_mk_agent/${library_path}/${name}`). For examples see README.md

Default value: ``undef``

##### `package_source`

Data type: `Optional[Stdlib::Absolutepath]`

Where to find the package, if you don't have it in a repo.

Default value: ``undef``

##### `package_provider`

Data type: `Optional[String[1]]`

What puppet package provider to use for installing it. Mandatory, if you gave `package_source`.

Default value: ``undef``

### `check_mk::server`

Does not create or manage omd sites as it should be done manually and in WATO

#### Examples

##### 

```puppet
include check_mk::server
```

#### Parameters

The following parameters are available in the `check_mk::server` class.

##### `required_packages`

Data type: `Optional[Array[String[1]]]`

install depending packages

Default value: ``undef``

##### `htpasswd_users`

Data type: `Optional[Hash[String[1], Hash[String[1], String[1]]]]`

hash of users per omd site, supports wildcard * (= all sites)

Default value: ``undef``

## Defined types

### `check_mk::client::configuration_item`

delets not managed files
rollout either per template or per file content string

#### Examples

##### 

```puppet
check_mk::client::configuration_item { 'namevar': config => 'my\ncontent', }
```

#### Parameters

The following parameters are available in the `check_mk::client::configuration_item` defined type.

##### `config`

Data type: `Variant[String[1], Hash]`

Give a String for direct `file content` or a hash to deploy the config per epp template. For examples see README.md

##### `item_path`

Data type: `Stdlib::Absolutepath`

Where to put the file. Defaults to `$::check_mk::client::configuration_item_path`

Default value: `$::check_mk::client::configuration_item_path`

##### `mode`

Data type: `String[1]`

Which file mode to set. Defaults to `$::check_mk::client::configuration_item_default_mode`

Default value: `$::check_mk::client::configuration_item_default_mode`

##### `epp_path`

Data type: `Optional[String[1]]`

In which path to find to epp template. Defaults to `$::check_mk::client::configuration_item_default_epp_path`. The template has to be named as the namevar of the configuration_item.

Default value: `$::check_mk::client::configuration_item_default_epp_path`

### `check_mk::client::library_item`

delets not managed files
rollout either per source (content == undef) or per file content string

#### Examples

##### 

```puppet
check_mk::client::library_item { 'namevar': library_path => 'plugin', content => 'my\nfancy\ncmk plugin', }
```

#### Parameters

The following parameters are available in the `check_mk::client::library_item` defined type.

##### `library_path`

Data type: `String[1]`

Is the 'type' of the item. Is usually one of 'plugin' or 'local' (for a cmk local check)

##### `mode`

Data type: `String[1]`

Which file mode to set. Defaults to `$::check_mk::client::library_item_default_mode`

Default value: `$::check_mk::client::library_item_default_mode`

##### `exec_interval`

Data type: `Optional[Integer[0]]`

In which interval the item should be executed (cached). Defaults to `$::check_mk::client::library_item_default_exec_interval`

Default value: `$::check_mk::client::library_item_default_exec_interval`

##### `puppet_path`

Data type: `Optional[String[1]]`

Where to find the item, if $content is not given. The modules searches in "${puppet_path}/${library_path}/${namevar}",

Default value: `$::check_mk::client::library_item_default_file_source_path`

##### `content`

Data type: `Optional[String[1]]`

A string for direct 'file content' for the item

Default value: ``undef``

##### `required_packages`

Data type: `Optional[Array[String[1]]]`

Installes additional packages, if an item requires it.

Default value: ``undef``
