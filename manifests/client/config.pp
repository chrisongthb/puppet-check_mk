# @summary This class is called from check_mk::client to configure base things
#
# Creates basic files
# Not managed files will be deleted
#
# @api private
#
class check_mk::client::config (
  $configuration_item_path = $::check_mk::client::configuration_item_path,
  $library_item_path       = $::check_mk::client::library_item_path,
){
  assert_private()

  # purge not managed files
  [ $configuration_item_path, $library_item_path ].each|String[1] $fl|{
    file { $fl:
      ensure  => 'directory',
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      purge   => true,
      recurse => true,
      force   => true,
    }
  }

  # logwatch.state must always be present.
  # check_mk stores the current position of logfiles there
  file { "${configuration_item_path}/logwatch.state":
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }
}
