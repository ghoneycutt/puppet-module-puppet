# == Class: puppet::server
#
# Manages puppetserver
#
# @param autosign_entries
#   Optional array of entries that will be autosigned.
#
# @param ca
#   Determines if the system is a puppet CA (certificate authority).
#   There should be only one CA per cluster of puppet masters.
#
# @param dns_alt_names
#   Value of the dns_alt_names option in puppet.conf.
#
# @param enc
#   The absolute path to an ENC. If this is set, it will be the value
#   for the external_nodes option in puppet.conf and the node_terminus
#   option will be set to 'exec'.
#
# @param memory_size
#   The amount of memory allocated to the puppetserver. This is passed
#   to the Xms and Xmx arguments for java. It must be a whole number
#   followed by the unit 'm' for MB or 'g' for GB.
#
# @param sysconfig_path
#   The absolute path to the puppetserver sysconfig file.
#
class puppet::server (
  Boolean                          $ca = false,
  Variant[Array[String, 1], Undef] $autosign_entries = undef,
  Stdlib::Absolutepath             $sysconfig_path = '/etc/sysconfig/puppetserver',
  Pattern[/^\d+(m|g)$/]            $memory_size = '2g', # only m and g are appropriate for unit
  Optional[Stdlib::Absolutepath]   $enc = undef,
  Optional[String]                 $dns_alt_names = undef,
) {
  include puppet

  $ini_defaults = {
    ensure  => 'present',
    path    => $puppet::config_path,
    section => 'master',
    require => File['puppet_config'],
    notify  => Service['puppetserver'],
  }

  $non_conditional_ini_settings = {
    'vardir'  => { setting => 'vardir', value => '/opt/puppetlabs/server/data/puppetserver' },
    'logdir'  => { setting => 'logdir', value => '/var/log/puppetlabs/puppetserver' },
    'rundir'  => { setting => 'rundir', value => '/var/run/puppetlabs/puppetserver' },
    'pidfile' => { setting => 'pidfile', value => '/var/run/puppetlabs/puppetserver/puppetserver.pid' },
    'codedir' => { setting => 'codedir', value => '/etc/puppetlabs/code' },
    'ca'      => { setting => 'ca', value => $ca },
  }

  if $enc != undef {
    $ini_enc_settings = {
      'node_terminus'  => { setting => 'node_terminus', value => 'exec' },
      'external_nodes' => { setting => 'external_nodes', value => $enc },
    }
  } else {
    $ini_enc_settings = {}
  }

  if $dns_alt_names != undef {
    $ini_dns_alt_names_settings = {
      'dns_alt_names' => { setting => 'dns_alt_names', value => $dns_alt_names },
    }
  } else {
    $ini_dns_alt_names_settings = {}
  }

  $ini_settings_merged = $non_conditional_ini_settings + $ini_enc_settings + $ini_dns_alt_names_settings
  create_resources('ini_setting', $ini_settings_merged, $ini_defaults)

  # Ensure that puppet.conf settings in [main] also trigger a restart of
  # puppetserver
  Ini_setting <| tag == 'puppet' and section == 'main' |> ~> Service['puppetserver']

  file { 'puppetserver_sysconfig':
    ensure  => 'file',
    path    => $sysconfig_path,
    content => template('puppet/puppetserver_sysconfig.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { 'autosign_config':
    ensure  => 'file',
    path    => '/etc/puppetlabs/puppet/autosign.conf',
    content => template('puppet/autosign.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['puppetserver'],
  }

  service { 'puppetserver':
    ensure    => 'running',
    enable    => true,
    subscribe => [
      File['puppet_config'],
      File['puppetserver_sysconfig'],
    ],
  }
}
