# check_mk server class
#
# htpasswd_users is for example:
# $htpasswd_users = {
#       '*'          => {'omdadmin' => '$1$451319$dlsdfjghlkjsfngkjnj45n63456'},
#       'ebnrefmain' => {'bi' => '$1$123456asdflj234rsdfgsfd'},
#       'test'       => {'bi' => '$1$123456asdflj234rsdfgsfd', 'test' => '$1$test'}
# }
#

class check_mk::server (
  Optional[Array[String[1]]]                            $required_packages = undef,
  Optional[Hash[String[1], Hash[String[1], String[1]]]] $htpasswd_users    = undef,
) {

  # initialize class check_mk::server
  class { 'check_mk::server::install': }
  -> class { 'check_mk::server::config': }
  ~> class { 'check_mk::server::service': }
  -> Class['check_mk::server']

}
