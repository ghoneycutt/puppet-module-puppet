# == Class: puppet
#
# Manages puppet agent
#
class puppet (
  String                                  $certname = $::fqdn,
  Variant[Enum['true', 'false'], Boolean] $run_every_thirty = true, #lint:ignore:quoted_booleans
  Variant[Enum['true', 'false'], Boolean] $run_in_noop = true, #lint:ignore:quoted_booleans
  String                                  $cron_command = '/opt/puppetlabs/bin/puppet agent --onetime --no-daemonize --no-usecacheonfailure --detailed-exitcodes --no-splay',
  Variant[Enum['true', 'false'], Boolean] $run_at_boot = true, #lint:ignore:quoted_booleans
  String                                  $config_path = '/etc/puppetlabs/puppet/puppet.conf',
  String                                  $server = 'puppet',
  String                                  $ca_server = 'puppet',
  String                                  $env = $environment,
  Variant[Enum['true', 'false'], Boolean] $graph = false, #lint:ignore:quoted_booleans
  String                                  $agent_sysconfig_path = '/etc/sysconfig/puppet',
  Hash                                    $custom_settings = {},
) {

  if $config_path != undef {
    validate_absolute_path($config_path)
  }

  if $agent_sysconfig_path != undef {
    validate_absolute_path($agent_sysconfig_path)
  }

  if is_string($run_every_thirty) == true {
    $run_every_thirty_bool = str2bool($run_every_thirty)
  } else {
    $run_every_thirty_bool = $run_every_thirty
  }

  if is_string($run_in_noop) == true {
    $run_in_noop_bool = str2bool($run_in_noop)
  } else {
    $run_in_noop_bool = $run_in_noop
  }

  if is_string($run_at_boot) == true {
    $run_at_boot_bool = str2bool($run_at_boot)
  } else {
    $run_at_boot_bool = $run_at_boot
  }

  if $run_every_thirty_bool == true {
    $cron_run_one = fqdn_rand(30)
    $cron_run_two = fqdn_rand(30) + 30
    $cron_minute  = [ $cron_run_one, $cron_run_two]
    $cron_ensure  = 'present'
  } else {
    $cron_ensure = 'absent'
    $cron_minute = undef
  }

  if $run_in_noop_bool == true {
    $cron_command_real = "${cron_command} --noop"
  } else {
    $cron_command_real = $cron_command
  }

  cron { 'puppet_agent_every_thirty':
    ensure  => $cron_ensure,
    command => $cron_command_real,
    user    => 'root',
    hour    => '*',
    minute  => $cron_minute,
  }

  if $run_at_boot_bool == true {
    $at_boot_ensure = 'present'
  } else {
    $at_boot_ensure = 'absent'
  }

  cron { 'puppet_agent_once_at_boot':
    ensure  => $at_boot_ensure,
    command => $cron_command_real,
    user    => 'root',
    special => 'reboot',
  }

  $ini_defaults = {
    ensure  => 'present',
    path    => $::puppet::config_path,
    section => 'main',
    require => File['puppet_config'],
  }

  $ini_settings = {
    'server'              => { setting => 'server', value => $server,},
    'ca_server'           => { setting => 'ca_server', value => $ca_server,},
    # certname must be lower case
    # see https://puppet.com/docs/puppet/latest/configuration.html#certname and https://tickets.puppetlabs.com/browse/PUP-2551
    'certname'            => { setting => 'certname', value => downcase($certname),},
    'environment'         => { setting => 'environment', value => $env,},
    'trusted_node_data'   => { setting => 'trusted_node_data', value => true,},
    'graph'               => { setting => 'graph', value => $graph,},
  }
  create_resources('ini_setting', $ini_settings, $ini_defaults)
  create_resources('ini_setting', $custom_settings, $ini_defaults)

  file { 'puppet_config':
    ensure => 'file',
    path   => $config_path,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  file { 'puppet_agent_sysconfig':
    ensure  => 'file',
    path    => $agent_sysconfig_path,
    content => template('puppet/agent_sysconfig.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  service { 'puppet_agent_daemon':
    ensure => 'stopped',
    name   => 'puppet',
    enable => false,
  }
}
