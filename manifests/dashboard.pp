# == Class: puppet::dashboard
#
class puppet::dashboard (
  $dashboard_package         = 'puppet-dashboard',
  $database_config_path      = '/usr/share/puppet-dashboard/config/database.yml',
  $database_config_owner     = 'puppet-dashboard',
  $database_config_group     = 'puppet-dashboard',
  $database_config_mode      = '0640',
  $dashboard_user            = 'puppet-dashboard',
  $dashboard_group           = 'puppet-dashboard',
  $external_node_script_path = '/usr/share/puppet-dashboard/bin/external_node',
  $dashboard_fqdn            = "puppet.${::domain}",
  $htpasswd                  = undef,
  $htpasswd_path             = '/etc/puppet/dashboard.htpasswd',
  $port                      = '3000',
  $log_dir                   = '/var/log/puppet',
  $mysql_user                = 'dashboard',
  $mysql_password            = 'puppet',
  $mysql_max_packet_size     = '32M',
  $security                  = 'none',
) {

  validate_absolute_path($external_node_script_path)
  validate_absolute_path($htpasswd_path)
  validate_re($security, '^(none|htpasswd)$', "Security is <${security}> which does not match regex. Valid values are none and htpasswd.")

  package { 'puppet_dashboard':
    ensure => present,
    name   => $dashboard_package,
  }

  file { 'external_node_script':
    ensure  => file,
    content => template('puppet/external_node.erb'),
    path    => $external_node_script_path,
    owner   => $dashboard_user,
    group   => $dashboard_group,
    mode    => '0755',
    require => Package['puppet_dashboard'],
  }

  file { 'dashboard_sysconfig':
    ensure  => file,
    path    => '/etc/sysconfig/puppet-dashboard',
    content => template('puppet/dashboard_sysconfig.erb'),
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
    ensure    => stopped,
    enable    => false,
  }
}
