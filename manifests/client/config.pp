# config

class check_mk::client::config {

  # purge not managed files
  file { [ $::check_mk::client::configuration_item_path, $::check_mk::client::library_item_path ]:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    purge   => true,
    recurse => true,
    force   => true,
  }

  # logwatch.state must always be present.
  # check_mk remembers the current position of logfiles there
  file { "${::check_mk::client::configuration_item_path}/logwatch.state":
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }
}
