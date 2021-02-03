# This class is called from check_mk::server for service config.
# We set here the local WATO users in htpasswd

class check_mk::server::config {

  # handle htpasswd only, if given and if there is the `omdsites` fact
  if $::check_mk::server::htpasswd_users and $::facts[omdsites] {

    ##################################
    # validate hash
    # fail, if a site, configured in hiera, is not present.
    $::check_mk::server::htpasswd_users.each |String $configured_sitename, Hash $attribues| {
      if $configured_sitename != '*' {
        if ! has_key($::facts[omdsites], $configured_sitename) {
          fail("site ${configured_sitename} is not present on node ${::fqdn}. Please reconfigure check_mk::server::htpasswd_users")
        }
      }
    }

    ##################################
    # prepare configuration of htpasswd
    # htpasswd entries are ordered by alphabetically
    # default users (set in '*') are printed below site specific users
    $::facts[omdsites].each |String $sitename, Hash $attributes| {
      if $::check_mk::server::htpasswd_users[$sitename] { # only if there are specific users set
        sort(keys($::check_mk::server::htpasswd_users[$sitename])).each |Integer $index, String $key| {
          concat::fragment { "/opt/omd/sites/${sitename}/etc/htpasswd - ${key}":
            target  => "/opt/omd/sites/${sitename}/etc/htpasswd",
            order   => "1_${index}",
            content => "${key}:${check_mk::server::htpasswd_users[$sitename][$key]}\n", # e.g. 'bi:$1$123456asdflj234rsdfgsfd'
          }
        }
      }
      if $::check_mk::server::htpasswd_users['*'] != undef {
        sort(keys($::check_mk::server::htpasswd_users['*'])).each |Integer $index, String $key| {
          # we need 'if not defined', because we want to overwrite default users in specific site configurations
          # e.g. if cmkadmin has pw '123' in default-cfg (*), and pw '456' in site main, we
          # want the site specific pw '456', which is set above
          if ! defined(Concat::Fragment["/opt/omd/sites/${sitename}/etc/htpasswd - ${key}"]) {
            concat::fragment { "/opt/omd/sites/${sitename}/etc/htpasswd - ${key}":
              target  => "/opt/omd/sites/${sitename}/etc/htpasswd",
              order   => "2_${index}",
              content => "${key}:${check_mk::server::htpasswd_users['*'][$key]}\n", # e.g. 'bi:$1$123456asdflj234rsdfgsfd'
            }
          }
        }
      }
    }

    ##################################
    # configure htpasswd
    $::facts[omdsites].each |String $sitename, Hash $attributes| {
      concat { "/opt/omd/sites/${sitename}/etc/htpasswd":
        ensure => present,
        owner  => $sitename,
        group  => $sitename,
        mode   => '0660',
        warn   => true,
      }
    }
  }
}
