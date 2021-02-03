# installs required packages

class check_mk::client::install {

  ensure_packages(
    $::check_mk::client::package_name,
    { 'ensure' => $::check_mk::client::package_ensure }
  )

}
