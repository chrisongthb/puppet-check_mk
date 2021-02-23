# @summary Deploys one configuration file
#
# delets not managed files
# rollout either per template or per file content string
#
# @example
#   check_mk::client::configuration_item { 'namevar': config => 'my\ncontent', }
#
# @param config Give a String for direct `file content` or a hash to deploy the config per epp template. For examples see README.md
# @param item_path Where to put the file. Defaults to `$::check_mk::client::configuration_item_path`
# @param mode Which file mode to set. Defaults to `$::check_mk::client::configuration_item_default_mode`
# @param epp_path In which path to find to epp template. Defaults to `$::check_mk::client::configuration_item_default_epp_path`. The template has to be named as the namevar of the configuration_item.
#
define check_mk::client::configuration_item (
  Variant[Hash, Sensitive[String[1]], String[1]] $config,
  Stdlib::Absolutepath                           $item_path = $::check_mk::client::configuration_item_path,
  String[1]                                      $mode      = $::check_mk::client::configuration_item_default_mode,
  Optional[String[1]]                            $epp_path  = $::check_mk::client::configuration_item_default_epp_path,
){

  if $config =~ Hash {
    if ! $epp_path {
      fail('Expected param $epp_path, if $config is a Hash. Please specify where to find EPP templates.')
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
  else {
    file { "${item_path}/${name}.cfg":
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => $mode,
      content => $config,
    }
  }
}
