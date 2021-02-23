# @summary Installs and configures check_mk agent
#
# Library- and Configuration- items are indented for those, who don't want or can't use the agent bakery
# Not managed Library- and Configuration- items will be deleted!
#
# @example
#   include check_mk::client
#
# @param package_name The name of the Check_mk agent package
# @param package_ensure The `ensure` value to use when installing the agent. This option can be used to install a specific package version.
# @param configuration_item_path The Check_mk agent base configuration directory (e.g. `/etc/check_mk`)
# @param configuration_item_default_mode The default file mode for Check_mk agent configuration files. Can be overwritten per configuration_item
# @param library_item_path The base path of plugins, local checks (e.g. `/usr/lib/check_mk_agent`)
# @param library_item_default_mode The default file mode for Check_mk agent configuration files. Can be overwritten per library_item.
# @param library_item_default_exec_interval The default interval of plugins and local checks. This can be used to configure caching for explicit libs.
# @param library_item_default_file_source_path Where to find the sources of library items rolled out by `source` (and not by content). You can configure you own file storage here (could be an extra repo with special permissions for monitoring admins…)
# @param encryption_passphrase Wraps an instance of configuration_item and defines the encryption secret for the check_mk_agent.
# @param logwatch_entries Wraps an instance of configuration_item and defines logwatch entries for the check_mk_agent.
# @param plugin_configs Is a hash and wraps instances of configuration_item to provide a speaking name for monitoring admins. For examples see README.md
# @param configuration_items Is a hash and installes files in configuration_item_path (e.g. `/etc/check_mk/mrpe.cfg`). For examples see README.md
# @param configuration_item_default_epp_path Where to find epp templates, when the $config of a configuration_item is a hash. For examples see README.md
# @param plugins Is a hash and wraps instances of library_item to provide a speaking name for monitoring admins. For examples see README.md
# @param local_checks Is a hash and wraps instances of library_item to provide a speaking name for monitoring admins. For examples see README.md
# @param library_items Is a hash and installes files in library_item_path (e.g. `/usr/lib/check_mk_agent/${library_path}/${name}`). For examples see README.md
# @param package_source Where to find the package, if you don't have it in a repo.
# @param package_provider What puppet package provider to use for installing it. Mandatory, if you gave `package_source`.
#
class check_mk::client (
  String[1]                                                    $package_name,
  String[1]                                                    $package_ensure,
  Stdlib::Absolutepath                                         $configuration_item_path,
  String[1]                                                    $configuration_item_default_mode,
  Stdlib::Absolutepath                                         $library_item_path,
  String[1]                                                    $library_item_default_mode,
  Optional[Integer[0]]                                         $library_item_default_exec_interval    = undef,
  Optional[String[1]]                                          $library_item_default_file_source_path = undef,
  Optional[String[1]]                                          $encryption_passphrase                 = undef,
  Optional[Hash[String[1],Array[String[1]]]]                   $logwatch_entries                      = undef,
  Optional[Hash[String[1],Hash]]                               $plugin_configs                        = undef,
  Optional[Hash]                                               $configuration_items                   = undef,
  Optional[String[1]]                                          $configuration_item_default_epp_path   = undef,
  Optional[Hash[String[1],Optional[Hash[String[1],NotUndef]]]] $plugins                               = undef,
  Optional[Hash[String[1],Optional[Hash[String[1],NotUndef]]]] $local_checks                          = undef,
  Optional[Hash]                                               $library_items                         = undef,
  Optional[Stdlib::Absolutepath]                               $package_source                        = undef,
  Optional[String[1]]                                          $package_provider                      = undef,
){

  contain ::check_mk::client::install
  contain ::check_mk::client::config

  Class['::check_mk::client::install']
  -> Class['::check_mk::client::config']

  # ##############################
  # manage configuration_items

  # manage encryption.cfg
  if $encryption_passphrase {
    ::check_mk::client::configuration_item { 'encryption':
      mode   => '0400',
      config => Sensitive("PASSPHRASE=${encryption_passphrase}\nENCRYPTED=yes\nENCRYPTED_RT=yes\n"),
    }
  }

  # manage logwatch.cfg
  if $logwatch_entries {
    ::check_mk::client::configuration_item { 'logwatch':
      config => inline_template("<% @logwatch_entries.map do |logfile, entries| -%><%= logfile %>\n<% entries.each do |entry| -%>  <%= entry %>\n<% end -%>\n<% end -%>"),
    }
  }

  # manage plugin configs
  if $plugin_configs {
    $plugin_configs.each |String $plugin_config, Hash $attributes| {
      ::check_mk::client::configuration_item { $plugin_config:
        config => $attributes,
      }
    }
  }

  # configure all other configuration items configured in hiera
  if $configuration_items {
    $configuration_items.each |String $configuration_item, Hash $attributes| {
      Resource[check_mk::client::configuration_item] {
        $configuration_item: * => $attributes;
      }
    }
  }

  # ##############################
  # manage library_items

  # plugins
  if $plugins {
    $plugins.each |String $plugin, Optional[Hash] $attributes| {
      $attributes_real = $attributes ? {
        Undef   => {},
        default => $attributes,
      }
      Resource[::check_mk::client::library_item] {
        $plugin: * => $attributes_real;
        default: * => { library_path => 'plugins' };
      }
    }
  }

  # local checks
  if $local_checks {
    $local_checks.each |String $local_check, Optional[Hash] $attributes| {
      $attributes_real = $attributes ? {
        Undef   => {},
        default => $attributes,
      }
      Resource[::check_mk::client::library_item] {
        $local_check: * => $attributes_real;
        default:      * => { library_path => 'local' };
      }
    }
  }

  # configure all other library items configured in hiera
  if $library_items {
    $library_items.each |String $library_item, Hash $attributes| {
      Resource[check_mk::client::library_item] {
        $library_item: * => $attributes;
      }
    }
  }
}
