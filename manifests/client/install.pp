# @summary This class is called from check_mk::client to install the agent
#
# Just installes the agent package
# The module does not care where to the the package from, if you want to install it from soruce.
#
# @api private
#
class check_mk::client::install (
  $package_name     = $::check_mk::client::package_name,
  $package_ensure   = $::check_mk::client::package_ensure,
  $package_source   = $::check_mk::client::package_source,
  $package_provider = $::check_mk::client::package_provider,

){
  assert_private()

  if $package_source {
    if $package_provider {
      package { 'check_mk_agent':
        ensure   => present,
        name     => $package_name,
        provider => $package_provider,
        source   => $package_source,
      }
    }
    else {
      fail('You have to provide check_mk::client::package_provider, if you want to install the package from source.')
    }
  }
  else {
    package { 'check_mk_agent':
      ensure => $package_ensure,
      name   => $package_name,
    }
  }

}
