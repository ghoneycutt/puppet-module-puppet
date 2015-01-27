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
    }
    'Debian': {
      $default_database_config_group = 'www-data'
      $default_htpasswd_group        = 'www-data'

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

  include puppet::dashboard::maintenance
  include puppet::passenger

  case type($manage_mysql_options) {
    'boolean': {
      $manage_mysql_options_real = $manage_mysql_options
    }
    'string': {
      $manage_mysql_options_real = str2bool($manage_mysql_options)
    }
    default: {
      fail("puppet::dashboard::server::manage_mysql_options supports booleans only and is <${manage_mysql_options}>.")
    }
  }

  if $manage_mysql_options_real == true {
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

  if $security == 'htpasswd' {
    # The custom fragment is needed as there is no support for Limits in directories in the apache module
    apache::vhost { 'dashboard':
      servername      => $dashboard_fqdn,
      port            => $port,
      docroot         => '/usr/share/puppet-dashboard/public/',
      docroot_owner   => 'puppet-dashboard',
      docroot_group   => 'puppet-dashboard',
      logroot         => "${log_dir}",
      error_log_file  => "dashboard_error.log",
      log_level       => 'warn',
      custom_fragment => '    <Location /reports/upload>
        <Limit POST>
           Order allow,deny
           Allow from all
           Satisfy any
        </Limit>
    </Location>

   <Location /nodes>
       <Limit GET>
           Order allow,deny
           Allow from all
           Satisfy any
       </Limit>
   </Location>',
      directories    => [
        { 'path'     => '/usr/share/puppet-dashboard/public/',
          'provider' => 'directory',
          'options'  => 'None',
        },
        { 'path'                => '/',
          'provider'            => 'location',
          'auth_type'           => 'basic',
          'auth_name'           => 'Puppet Dashboard',
          'auth_require'        => 'valid-user',
          'auth_basic_provider' => 'file',
          'auth_user_file'      => $htpasswd_path,
          'order'               => ['deny','allow'],
        },
      ],
    }

  } else {
    apache::vhost { 'dashboard':
      servername     => $dashboard_fqdn,
      port           => $port,
      docroot        => '/usr/share/puppet-dashboard/public/',
      docroot_owner  => 'puppet-dashboard',
      docroot_group  => 'puppet-dashboard',
      logroot        => "${log_dir}",
      error_log_file => "dashboard_error.log",
      log_level      => 'warn',
      directories    => [
        { 'path'     => '/usr/share/puppet-dashboard/public/',
          'provider' => 'directory',
          'options'  => 'None',
        },
      ],
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
