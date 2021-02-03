# deploys one configuration file
# delets not managed files
# rollout either per template or per file content string
#

define check_mk::client::configuration_item (
  Variant[String[1], Hash] $config,
  Stdlib::Absolutepath     $item_path = $::check_mk::client::configuration_item_path,
  String[1]                $mode      = $::check_mk::client::configuration_item_default_mode,
  Optional[String[1]]      $epp_path  = $::check_mk::client::configuration_item_default_epp_path,
){

  if $config =~ String[1] {
    file { "${item_path}/${name}.cfg":
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => $mode,
      content => $config,
    }
  }
  elsif $config =~ Hash {
    if ! $epp_path {
      fail('Expected param $epp_path, if $config is a Hash. Please specify where to search EPP templates.')
    }
    else {
      file { "${item_path}/${name}.cfg":
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        mode    => $mode,
        content => epp("${epp_path}/${name}.epp", { 'config' => $config }),
      }
    }
  }
}
