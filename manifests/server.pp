# @summary Configures Check_mk server
#
# Does not create or manage omd sites as it should be done manually and in WATO
#
# @example
#   include check_mk::server
#
# @param required_packages install depending packages
# @param htpasswd_users hash of users per omd site, supports wildcard * (= all sites)
#
class check_mk::server (
  Optional[Array[String[1]]]                            $required_packages = undef,
  Optional[Hash[String[1], Hash[String[1], String[1]]]] $htpasswd_users    = undef,
) {

  contain check_mk::server::install
  contain check_mk::server::config

  Class['check_mk::server::install']
  -> Class['check_mk::server::config']

}
