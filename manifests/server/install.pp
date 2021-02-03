# This class is called from check_mk::server for installation.

class check_mk::server::install {

  if $::check_mk::server::required_packages {
    ensure_packages( $::check_mk::server::required_packages, { 'ensure' => 'installed' })
  }

}
