# @summary This class is called from check_mk::client to install the agent
#
# Just installes the agent package
# The module does not care where to the the package from, if you want to install it from soruce.
#
# @api private
#
class check_mk::client::install {

  assert_private()

  contain check_mk::client

  if $check_mk::client::package_source {
    if $check_mk::client::package_provider {
      package { 'check_mk_agent':
        ensure   => present,
        name     => $check_mk::client::package_name,
        provider => $check_mk::client::package_provider,
        source   => $check_mk::client::package_source,
      }
    }
    else {
      fail('You have to provide check_mk::client::package_provider, if you want to install the package from source.')
    }
  }
  else {
    package { 'check_mk_agent':
      ensure => $check_mk::client::package_ensure,
      name   => $check_mk::client::package_name,
    }
  }

}
