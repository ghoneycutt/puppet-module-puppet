# == Class: puppet::dashboard
#
class puppet::dashboard (
  $dashboard_package     = 'puppet-dashboard',
  $database_config_path  = '/usr/share/puppet-dashboard/config/database.yml',
  $database_config_owner = 'puppet-dashboard',
  $database_config_group = 'puppet-dashboard',
  $database_config_mode  = '0640',
  $dashboard_fqdn        = "puppet.${::domain}",
  $port                  = '3000',
  $log_dir               = '/var/log/puppet',
  $mysql_user            = 'dashboard',
  $mysql_password        = 'puppet',
  $mysql_max_packet_size = '32M',
) {

  require 'passenger'
  include puppet::dashboard::maintenance

  class { 'mysql::server':
    config_hash => { 'max_allowed_packet' => $mysql_max_packet_size }
  }

  package { 'puppet_dashboard':
    ensure => present,
    name   => $dashboard_package,
  }

  file { 'database_config':
    ensure  => file,
    content => template('puppet/database.yml.erb'),
    path    => $database_config_path,
    owner   => $database_config_owner,
    group   => $database_config_group,
    mode    => $database_config_mode,
    require => Package['puppet_dashboard'],
  }

  file { 'dashboard_vhost':
    ensure  => file,
    path    => '/etc/httpd/conf.d/dashboard.conf',
    content => template('puppet/dashboard-vhost.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => [ File['httpd_vdir'],       # apache
#                Exec['compile-passenger'], # passenger
                ],
    notify  => Service['httpd'],           # apache
  }

  file { 'dashboard_sysconfig':
    ensure  => file,
    path    => '/etc/sysconfig/puppet-dashboard',
    content => template('puppet/dashboard_sysconfig.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  mysql::db { 'dashboard':
    user     => $mysql_user,
    password => $mysql_password,
    host     => 'localhost',
    grant    => ['all'],
    require  => [ Class['mysql::server'],
                  File['database_config'],
                ],
  }

  exec { 'migrate_dashboard_database':
    command     => 'rake RAILS_ENV=production db:migrate',
    onlyif      => 'rake RAILS_ENV=production db:version 2>/dev/null|grep ^\'Current version\' | awk -F : \'{print $2}\' | awk \'{print $1}\'|grep ^0$',
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    cwd         => '/usr/share/puppet-dashboard',
    refreshonly => true,
    subscribe   => Mysql::Db['dashboard'],
  }

  # Dashboard is ran under Passenger with Apache
  service { 'puppet-dashboard':
    ensure    => stopped,
    enable    => false,
    subscribe => File['dashboard_sysconfig'],
  }

  service { 'puppet-dashboard-workers':
    ensure    => running,
    enable    => true,
    subscribe => File['dashboard_sysconfig'],
  }
}
