# == Class: puppet::dashboard::server
#
class puppet::dashboard::server (
  $dashboard_workers         = $::processorcount,
  $database_config_path      = '/usr/share/puppet-dashboard/config/database.yml',
  $database_config_owner     = 'USE_DEFAULTS',
  $database_config_group     = 'USE_DEFAULTS',
  $database_config_mode      = '0640',
  $htpasswd                  = undef,
  $htpasswd_path             = '/etc/puppet/dashboard.htpasswd',
  $htpasswd_owner            = 'root',
  $htpasswd_group            = 'USE_DEFAULTS',
  $htpasswd_mode             = '0640',
  $log_dir                   = '/var/log/puppet',
  $manage_mysql_options      = true,
  $mysql_user                = 'dashboard',
  $mysql_password            = 'puppet',
  $mysql_max_packet_size     = '32M',
  $security                  = 'none',
  $vhost_path                = 'USE_DEFAULTS',
) inherits puppet::dashboard {

  validate_re($dashboard_workers, '^\d+$',
    "puppet::dashboard::server::dashboard_workers must be a digit. Detected value is <${dashboard_workers}>."
  )
  validate_absolute_path($htpasswd_path)
  validate_re($security, '^(none|htpasswd)$',
    "Security is <${security}> which does not match regex. Valid values are none and htpasswd."
  )

  case $::osfamily {
    'RedHat': {
      $default_database_config_group = $puppet::dashboard::dashboard_group_real
      $default_htpasswd_group        = 'apache'
      $default_vhost_path            = '/etc/httpd/conf.d/dashboard.conf'
    }
    'Debian': {
      $default_database_config_group = 'www-data'
      $default_htpasswd_group        = 'www-data'
      $default_vhost_path            = '/etc/apache2/sites-enabled/puppetdashboard'

      file { 'dashboard_workers_default':
        ensure  => file,
        path    => '/etc/default/puppet-dashboard-workers',
        content => template('puppet/puppet-dashboard-workers.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => Service['puppet-dashboard-workers'],
      }
    }
    default: {
      fail("puppet::dashboard::server supports osfamilies Debian and RedHat. Detected osfamily is <${::osfamily}>.")
    }
  }

  if $database_config_owner == 'USE_DEFAULTS' {
    $database_config_owner_real = $puppet::dashboard::dashboard_user_real
  } else {
    $database_config_owner_real = $database_config_owner
  }

  if $database_config_group == 'USE_DEFAULTS' {
    $database_config_group_real = $default_database_config_group
  } else {
    $database_config_group_real = $database_config_group
  }

  if $htpasswd_group == 'USE_DEFAULTS' {
    $htpasswd_group_real = $default_htpasswd_group
  } else {
    $htpasswd_group_real = $htpasswd_group
  }

  if $vhost_path == 'USE_DEFAULTS' {
    $vhost_path_real = $default_vhost_path
  } else {
    $vhost_path_real = $vhost_path
  }
  validate_absolute_path($vhost_path_real)

  require 'passenger'
  include puppet::dashboard::maintenance

  if $manage_mysql_options {
    class { 'mysql::server':
      override_options => {
        'mysqld' => {
          'max_allowed_packet' => $mysql_max_packet_size,
        }
      }
    }
  } else {
    include mysql::server
  }

  if $security == 'htpasswd' and $htpasswd != undef {

    Htpasswd {
      target => $htpasswd_path,
    }

    Htpasswd <||> -> File['dashboard_htpasswd_path']

    create_resources('htpasswd',$htpasswd)

    file { 'dashboard_htpasswd_path':
      ensure => file,
      path   => $htpasswd_path,
      owner  => $htpasswd_owner,
      group  => $htpasswd_group_real,
      mode   => $htpasswd_mode,
    }
  }

  file { 'database_config':
    ensure  => file,
    content => template('puppet/database.yml.erb'),
    path    => $database_config_path,
    owner   => $database_config_owner_real,
    group   => $database_config_group_real,
    mode    => $database_config_mode,
    require => Package[$puppet::dashboard::dashboard_package],
  }

  file { 'dashboard_vhost':
    ensure  => file,
    path    => $vhost_path_real,
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
    grant    => ['ALL'],
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
