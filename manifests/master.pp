# == Class: puppet::master
#
class puppet::master (
  $sysconfig_path  = 'USE_DEFAULTS',
  $rack_dir        = '/usr/share/puppet/rack/puppetmasterd',
  $puppet_user     = 'puppet',
  $manage_firewall = undef,
  $vhost_path      = 'USE_DEFAULTS',
) {

  case $::osfamily {
    'RedHat': {
      $default_sysconfig_path = '/etc/sysconfig/puppetmaster'
      $sysconfig_template     = 'puppetmaster_sysconfig.erb'
      $default_vhost_path     = '/etc/httpd/conf.d/puppetmaster.conf'
    }
    'Debian': {
      $default_sysconfig_path = '/etc/default/puppetmaster'
      $sysconfig_template     = 'puppetmaster_default.erb'
      $default_vhost_path     = '/etc/apache2/sites-enabled/puppetmaster'
    }
    default: {
      fail("puppet::master supports osfamilies Debian and RedHat. Detected osfamily is <${::osfamily}>.")
    }
  }

  include apache::mod::ssl
  include passenger
  include puppet::lint
  include puppet::master::maintenance

  if $sysconfig_path == 'USE_DEFAULTS' {
    $sysconfig_path_real = $default_sysconfig_path
  } else {
    $sysconfig_path_real = $sysconfig_path
  }
  validate_absolute_path($sysconfig_path_real)

  if $vhost_path == 'USE_DEFAULTS' {
    $vhost_path_real = $default_vhost_path
  } else {
    $vhost_path_real = $vhost_path
  }
  validate_absolute_path($vhost_path_real)

  if $manage_firewall == true {
    firewall { '8140 open port 8140 for Puppet Master':
      action => 'accept',
      dport  => 8140,
      proto  => 'tcp',
    }
  }

  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  file { '/etc/puppet/auth.conf': }

  file { '/etc/puppet/fileserver.conf': }

  file { 'puppetmaster_sysconfig':
    ensure  => file,
    path    => $sysconfig_path_real,
    content => template("puppet/${sysconfig_template}"),
  }

  # Puppetmaster service cannot be stopped as that would likely break the boot
  # strap process.
  service { 'puppetmaster':
    enable => false,
  }

  # Passenger
  puppet::mkdir_p { $rack_dir: }
  puppet::mkdir_p { "${rack_dir}/public": }
  puppet::mkdir_p { "${rack_dir}/tmp": }

  file { $rack_dir:
    ensure  => directory,
    require => Puppet::Mkdir_p[$rack_dir],
  }

  file { "${rack_dir}/public":
    ensure  => directory,
    require => Puppet::Mkdir_p["${rack_dir}/public"],
  }

  file { "${rack_dir}/tmp":
    ensure  => directory,
    require => Puppet::Mkdir_p["${rack_dir}/tmp"],
  }

  file { "${rack_dir}/config.ru":
    ensure => file,
    source => 'puppet:///modules/puppet/config.ru',
    owner  => $puppet_user,
    group  => 'root',
    mode   => '0644',
  }

  file { 'puppetmaster_vhost':
    ensure  => file,
    path    => $vhost_path_real,
    content => template('puppet/puppetmaster-vhost.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['httpd_vdir'],
    notify  => Service['httpd'],
  }
}
