# == Class: puppet::dashboard::server
#
class puppet::dashboard::server (
  $database_config_path      = '/usr/share/puppet-dashboard/config/database.yml',
  $database_config_owner     = 'puppet-dashboard',
  $database_config_group     = 'puppet-dashboard',
  $database_config_mode      = '0640',
  $htpasswd                  = undef,
  $htpasswd_path             = '/etc/puppet/dashboard.htpasswd',
  $log_dir                   = '/var/log/puppet',
  $mysql_user                = 'dashboard',
  $mysql_password            = 'puppet',
  $mysql_max_packet_size     = '32M',
  $security                  = 'none',
) inherits puppet::dashboard {

  validate_absolute_path($htpasswd_path)
  validate_re($security, '^(none|htpasswd)$', "Security is <${security}> which does not match regex. Valid values are none and htpasswd.")

  require 'passenger'
  include puppet::dashboard::maintenance

  class { 'mysql::server':
    config_hash => { 'max_allowed_packet' => $mysql_max_packet_size }
  }

  if $security == 'htpasswd' and $htpasswd != undef {

    Htpasswd {
      target => $htpasswd_path,
    }

    create_resources('htpasswd',$htpasswd)
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

  Service['puppet-dashboard-workers'] {
    ensure    => running,
    enable    => true,
    subscribe => File['dashboard_sysconfig'],
  }
}
