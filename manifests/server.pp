# == Class: puppet::server
#
# Manages puppetserver
#
class puppet::server (
  Variant[Enum['true', 'false'], Boolean] $ca = false, #lint:ignore:quoted_booleans
  Variant[Array[String, 1], Undef]        $autosign_entries = undef,
  String                                  $sysconfig_path = '/etc/sysconfig/puppetserver',
  String                                  $memory_size = '2g', # only m and g are appropriate for unit
  Optional[String]                        $enc = undef,
) {

  include ::puppet

  if $sysconfig_path != undef {
    validate_absolute_path($sysconfig_path)
  }

  validate_re($memory_size, '^\d+(m|g)$',
    "puppet::memory_size is <${memory_size}> and must be an integer following by the unit 'm' or 'g'.")

  $ini_defaults = {
    ensure  => 'present',
    path    => $::puppet::config_path,
    section => 'master',
    require => File['puppet_config'],
    notify  => Service['puppetserver'],
  }

  $non_conditional_ini_settings = {
    'vardir'  => { setting => 'vardir', value => '/opt/puppetlabs/server/data/puppetserver',},
    'logdir'  => { setting => 'logdir', value => '/var/log/puppetlabs/puppetserver',},
    'rundir'  => { setting => 'rundir', value => '/var/run/puppetlabs/puppetserver',},
    'pidfile' => { setting => 'pidfile', value => '/var/run/puppetlabs/puppetserver/puppetserver.pid',},
    'codedir' => { setting => 'codedir', value =>'/etc/puppetlabs/code',},
    'ca'      => { setting => 'ca', value => $ca,},
  }

  if $enc != undef {
    validate_absolute_path($enc)
    $ini_enc_settings = {
      'node_terminus'  => { setting => 'node_terminus', value => 'exec' },
      'external_nodes' => { setting => 'external_nodes', value => $enc },
    }
  } else {
    $ini_enc_settings = {}
  }

  $ini_settings_merged = $non_conditional_ini_settings + $ini_enc_settings
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
