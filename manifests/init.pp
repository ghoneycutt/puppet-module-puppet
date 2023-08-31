# == Class: puppet
#
# Manages puppet agent
#
# @param agent_sysconfig_path
#   The absolute path to the puppet agent sysconfig file.
#
# @param ca_server
#   The name of the puppet CA server.
#
# @param certname
#   The certificate name for the client.
#
# @param config_path
#   The absolute path to the puppet config file.
#
# @param cron_command
#   Command that will be run from cron for the puppet agent.
#
# @param custom_settings
#   A hash that allows you to define and set any settings in puppet.conf.
#   For each setting use a nested hash and provide the section and the name
#   and value of the setting.
#
#   Example:
#   ```
#   $custom_settings = {
#     'name'  => { 'section' => 'master', 'setting' => 'codedir', 'value' => '/specific/path' },
#     'other' => { 'section' => 'agent',  'setting' => 'server',  'value' => 'specific.server.local' },
#   }
#   ```
#
# @param env
#   Value of environment option in puppet.conf which defaults to the
#   environment of the current puppet run. By setting this parameter, you
#   can specify an environment on the command line (`puppet agent -t
#   --environment foo`) and it will not trigger a change to the puppet.conf.
#
# @param graph
#   Value of the graph option in puppet.conf.
#
# @param run_at_boot
#   Determine if a cron job should present that will run the puppet agent at
#   boot time.
#
# @param run_every_thirty
#   Determines if a cron job to run the puppet agent every thirty minutes
#   should be present.
#
# @param run_in_noop
#   Determines if the puppet agent should run in noop mode. This is done by
#   appending '--noop' to the `cron_command` parameter.
#
# @param server
#   The name of the puppet server.
#
class puppet (
  String               $certname             = $facts['networking']['fqdn'],
  Boolean              $run_every_thirty     = true,
  Boolean              $run_in_noop          = true,
  String               $cron_command         = '/opt/puppetlabs/bin/puppet agent --onetime --no-daemonize --no-usecacheonfailure --detailed-exitcodes --no-splay', #lint:ignore:140chars
  Boolean              $run_at_boot          = true,
  Stdlib::Absolutepath $config_path          = '/etc/puppetlabs/puppet/puppet.conf',
  String               $server               = 'puppet',
  String               $ca_server            = 'puppet',
  String               $env                  = $environment,
  Boolean              $graph                = false,
  Stdlib::Absolutepath $agent_sysconfig_path = '/etc/sysconfig/puppet',
  Hash                 $custom_settings      = {},
) {
  if $run_every_thirty == true {
    $cron_run_one = fqdn_rand(30)
    $cron_run_two = fqdn_rand(30) + 30
    $cron_minute  = [$cron_run_one, $cron_run_two]
    $cron_ensure  = 'present'
  } else {
    $cron_ensure = 'absent'
    $cron_minute = undef
  }

  if $run_in_noop == true {
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

  if $run_at_boot == true {
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
    path    => $puppet::config_path,
    section => 'main',
    require => File['puppet_config'],
  }

  $ini_settings = {
    'server'              => { setting => 'server', value => $server },
    'ca_server'           => { setting => 'ca_server', value => $ca_server },
    'certname'            => { setting => 'certname', value => $certname },
    'environment'         => { setting => 'environment', value => $env },
    'trusted_node_data'   => { setting => 'trusted_node_data', value => true },
    'graph'               => { setting => 'graph', value => $graph },
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
