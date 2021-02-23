# @summary deploys one library_item file, that is e.g. a plugin or a local check
#
# delets not managed files
# rollout either per source (content == undef) or per file content string
#
# @example
#   check_mk::client::library_item { 'namevar': library_path => 'plugin', content => 'my\nfancy\ncmk plugin', }
#
# @param library_path Is the 'type' of the item. Is usually one of 'plugin' or 'local' (for a cmk local check)
# @param mode Which file mode to set. Defaults to `$::check_mk::client::library_item_default_mode`
# @param exec_interval In which interval the item should be executed (cached). Defaults to `$::check_mk::client::library_item_default_exec_interval`
# @param puppet_path Where to find the item, if $content is not given. The modules searches in "${puppet_path}/${library_path}/${namevar}",
# @param content A string for direct 'file content' for the item
# @param required_packages Installes additional packages, if an item requires it.
#
define check_mk::client::library_item (
  String[1]                  $library_path,
  String[1]                  $mode                = $::check_mk::client::library_item_default_mode,
  Optional[Integer[0]]       $exec_interval       = $::check_mk::client::library_item_default_exec_interval,
  Optional[String[1]]        $puppet_path         = $::check_mk::client::library_item_default_file_source_path,
  Optional[String[1]]        $content             = undef,
  Optional[Array[String[1]]] $required_packages   = undef,
){

  contain check_mk::client

  # install required packages, if given
  if $required_packages {
    ensure_packages($required_packages, {'ensure' => 'installed'})
  }

  # create library path directory, e.g. plugins or local
  ensure_resource(
    'file',
    "${::check_mk::client::library_item_path}/${library_path}",
    {
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      purge   => true,
      recurse => true,
      force   => true,
    }
  )

  # create interval directory, if given
  unless $exec_interval == undef {
    ensure_resource(
      'file',
      "${::check_mk::client::library_item_path}/${library_path}/${exec_interval}",
      {
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        purge   => true,
        recurse => true,
        force   => true,
      }
    )
  }

  # rollout library_item
  if $content != undef {
    file { "${::check_mk::client::library_item_path}/${library_path}/${exec_interval}/${name}":
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => $mode,
      content => $content,
    }
  }
  else {
    if ! $puppet_path {
      fail("Expected param \$puppet_path, if \$content is not given. Please specify where to find file source for library item '${name}'.")
    }
    else {
      file { "${::check_mk::client::library_item_path}/${library_path}/${exec_interval}/${name}":
        ensure => 'file',
        owner  => 'root',
        group  => 'root',
        mode   => $mode,
        source => "${puppet_path}/${library_path}/${name}",
      }
    }
  }

}
