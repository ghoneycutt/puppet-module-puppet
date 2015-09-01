# == Class: puppet::dashboard
#
class puppet::dashboard (
  $dashboard_package         = 'puppet-dashboard',
  $dashboard_user            = 'USE_DEFAULTS',
  $dashboard_group           = 'USE_DEFAULTS',
  $sysconfig_path            = 'USE_DEFAULTS',
  $external_node_script_path = '/usr/share/puppet-dashboard/bin/external_node',
  $dashboard_fqdn            = "puppet.${::domain}",
  $port                      = '3000',
) {

  validate_absolute_path($external_node_script_path)
  if type3x($dashboard_package) != 'String' and type3x($dashboard_package) != 'Array' {
    fail('puppet::dashboard::dashboard_package must be a string or an array.')
  }

  case $::osfamily {
    'RedHat': {
      $default_sysconfig_path  = '/etc/sysconfig/puppet-dashboard'
      $sysconfig_template      = 'dashboard_sysconfig.erb'
      $default_dashboard_user  = 'puppet-dashboard'
      $default_dashboard_group = 'puppet-dashboard'
    }
    'Debian': {
      $default_sysconfig_path  = '/etc/default/puppet-dashboard'
      $sysconfig_template      = 'dashboard_default.erb'
      $default_dashboard_user  = 'puppet'
      $default_dashboard_group = 'puppet'
    }
    default: {
      fail("puppet::dashboard supports osfamilies Debian and RedHat. Detected osfamily is <${::osfamily}>.")
    }
  }

  if $sysconfig_path == 'USE_DEFAULTS' {
    $sysconfig_path_real = $default_sysconfig_path
  } else {
    $sysconfig_path_real = $sysconfig_path
  }
  validate_absolute_path($sysconfig_path_real)

  if $dashboard_user == 'USE_DEFAULTS' {
    $dashboard_user_real = $default_dashboard_user
  } else {
    $dashboard_user_real = $dashboard_user
  }

  if $dashboard_group == 'USE_DEFAULTS' {
    $dashboard_group_real = $default_dashboard_group
  } else {
    $dashboard_group_real = $dashboard_group
  }

  package { $dashboard_package:
    ensure => present,
  }

  file { 'external_node_script':
    ensure  => file,
    content => template('puppet/external_node.erb'),
    path    => $external_node_script_path,
    owner   => $dashboard_user_real,
    group   => $dashboard_group_real,
    mode    => '0755',
    require => Package[$dashboard_package],
  }

  file { 'dashboard_sysconfig':
    ensure  => file,
    path    => $sysconfig_path_real,
    content => template("puppet/${sysconfig_template}"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  # Dashboard is ran under Passenger with Apache
  service { 'puppet-dashboard':
    ensure    => stopped,
    enable    => false,
    subscribe => File['dashboard_sysconfig'],
  }

  service { 'puppet-dashboard-workers':
    ensure => stopped,
    enable => false,
  }
}
