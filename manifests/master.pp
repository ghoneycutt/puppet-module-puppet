# == Class: puppet::master
#
class puppet::master (
  $rack_dir        = '/usr/share/puppet/rack/puppetmasterd',
  $puppet_user     = 'puppet',
  $manage_firewall = undef,
) {

  include apache::mod::ssl
  include common
  include passenger
  include puppet::lint
  include puppet::master::maintenance

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

  file { '/etc/sysconfig/puppetmaster':
    ensure  => file,
    content => template('puppet/puppetmaster_sysconfig.erb'),
  }

  # Puppetmaster service cannot be stopped as that would likely break the boot
  # strap process.
  service { 'puppetmaster':
    enable => false,
  }

  # Passenger
  common::mkdir_p { $rack_dir: }
  common::mkdir_p { "${rack_dir}/public": }
  common::mkdir_p { "${rack_dir}/tmp": }

  file { $rack_dir:
    ensure  => directory,
    require => Common::Mkdir_p[$rack_dir],
  }

  file { "${rack_dir}/public":
    ensure  => directory,
    require => Common::Mkdir_p["${rack_dir}/public"],
  }

  file { "${rack_dir}/tmp":
    ensure  => directory,
    require => Common::Mkdir_p["${rack_dir}/tmp"],
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
    path    => '/etc/httpd/conf.d/puppetmaster.conf',
    content => template('puppet/puppetmaster-vhost.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['httpd_vdir'],
    notify  => Service['httpd'],
  }
}
