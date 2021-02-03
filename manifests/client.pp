# check_mk client class
# TODO: configuration items
#
# #######
# example logwatch_entries:
#   ---
#   check_mk::client::logwatch_entries:
#     '/var/log/syslog':
#       - 'C .*EXT4-fs warning.*ext4_end_bio.*I/O error.*'
#       - 'C .* segfault at .*'
#     '/backup/postgres/logs/error.log':
#       - 'C .'
#
# #######
# example plugin_configs (see header in check_mk/templates/client/plugin_configs/* for more doc):
#   ---
#   check_mk::client::plugin_configs:
#     'el_statusseiten':
#       'hase_status': 'https://ecmhan01:8443/api/hase-status'
#       'boa_status': 'https://ecmhan01:8446/boa/status'
#     'apache_status':
#       'localhost_80':
#         protocol: 'http'
#         host: 'localhost'
#         port: 80
#       'localhost_443':
#         protocol: 'https'
#         host: 'localhost'
#         port: 443
#
# #######
# example plugins:
#   ---
#   check_mk::client::plugins:
#     entropy_avail:
#     mk_inventory.linux:
#     el_kvm:
#       exec_interval: 120
#
# #######
# example local_checks:
#   ---
#   check_mk::client::local_checks:
#     my_plugin:
#       required_packages:
#         - "nmon"
#       exec_interval: 3600
#       content: "#!/bin/bash\necho new line is working!\n"
#     check_locale:
#     check_foo:
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
      config => "PASSPHRASE=${encryption_passphrase}\nENCRYPTED=yes\nENCRYPTED_RT=yes\n",
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
