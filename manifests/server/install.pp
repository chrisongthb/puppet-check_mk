# @summary This class is called from check_mk::server for installation of required packages.
#
# Installs packages required for omd sites
#
# @api private
#
class check_mk::server::install {

  assert_private()

  contain check_mk::server
  $required_packages = $::check_mk::server::required_packages

  if $required_packages {
    $required_packages.each|String[1] $pkg|{
      package { $pkg:
        ensure => 'installed',
      }
    }
  }
}
