# == Class: puppet::master
#
class puppet::master (
  $sysconfig_path  = 'USE_DEFAULTS',
  $rack_dir        = '/usr/share/puppet/rack/puppetmasterd',
  $puppet_user     = 'puppet',
  $manage_firewall = undef,
) {

  case $::osfamily {
    'RedHat': {
      $default_sysconfig_path = '/etc/sysconfig/puppetmaster'
      $sysconfig_template     = 'puppetmaster_sysconfig.erb'
    }
    'Debian': {
      $default_sysconfig_path = '/etc/default/puppetmaster'
      $sysconfig_template     = 'puppetmaster_default.erb'
    }
    default: {
      fail("puppet::master supports osfamilies Debian and RedHat. Detected osfamily is <${::osfamily}>.")
    }
  }

  include puppet::passenger
  include apache::mod::ssl
  include apache::mod::headers
  include common
  include puppet::lint
  include puppet::master::maintenance

  if $sysconfig_path == 'USE_DEFAULTS' {
    $sysconfig_path_real = $default_sysconfig_path
  } else {
    $sysconfig_path_real = $sysconfig_path
  }
  validate_absolute_path($sysconfig_path_real)

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

  apache::vhost { 'puppetmaster':
    servername          => $fqdn,
    port                => '8140',
    docroot             => "${rack_dir}/public",
    ssl                 => true,
    ssl_cipher          => "HIGH:!ADH:RC4+RSA:-MEDIUM:-LOW:-EXP",
    ssl_cert            => "/var/lib/puppet/ssl/certs/${fqdn}.pem",
    ssl_key             => "/var/lib/puppet/ssl/private_keys/${fqdn}.pem",
    ssl_chain           => "/var/lib/puppet/ssl/ca/ca_crt.pem",
    ssl_ca              => "/var/lib/puppet/ssl/ca/ca_crt.pem",
    ssl_crl             => "/var/lib/puppet/ssl/ca/ca_crl.pem",
    ssl_verify_client   => 'optional',
    ssl_verify_depth    => '1',
    ssl_options         => '+StdEnvVars +ExportCertData',
    ssl_protocol        => 'All -SSLv2 -SSLv3',
    directories         => {
      path              => "${rack_dir}/",
      options           => 'None',
      passenger_enabled => 'on',
    },
    request_headers     => [
      'unset X-Forwarded-For',
      'set X-SSL-Subject %{SSL_CLIENT_S_DN}e',
      'set X-Client-DN %{SSL_CLIENT_S_DN}e',
      'set X-Client-Verify %{SSL_CLIENT_VERIFY}e',
    ],
  }
}
