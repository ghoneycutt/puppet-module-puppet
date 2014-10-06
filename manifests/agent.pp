# == Class: puppet::agent
#
# Manage Puppet agents
#
# We also run puppet once at boot via cron, regardless of if you normally run
# puppet from cron or as a daemon.
#
class puppet::agent (
  $certname                     = $::fqdn,
  $config_path                  = '/etc/puppet/puppet.conf',
  $config_owner                 = 'root',
  $config_group                 = 'root',
  $config_mode                  = '0644',
  $env                          = $::env,
  $puppet_server                = 'puppet',
  $puppet_masterport            = 'UNSET',
  $puppet_ca_server             = 'UNSET',
  $is_puppet_master             = false,
  $run_method                   = 'service',
  $run_interval                 = '30',
  $run_in_noop                  = false,
  $cron_command                 = '/usr/bin/puppet agent --onetime --ignorecache --no-daemonize --no-usecacheonfailure --detailed-exitcodes --no-splay',
  $run_at_boot                  = true,
  $puppet_binary                = '/usr/bin/puppet',
  $symlink_puppet_binary_target = '/usr/local/bin/puppet',
  $symlink_puppet_binary        = false,
  $agent_sysconfig              = 'USE_DEFAULTS',
  $agent_sysconfig_ensure       = 'USE_DEFAULTS',
  $daemon_name                  = 'puppet',
  $stringify_facts              = true,
) {

  if type($run_in_noop) == 'String' {
    $run_in_noop_bool = str2bool($run_in_noop)
  } else {
    $run_in_noop_bool = $run_in_noop
  }
  validate_bool($run_in_noop_bool)

  if type($run_at_boot) == 'String' {
    $run_at_boot_bool = str2bool($run_at_boot)
  } else {
    $run_at_boot_bool = $run_at_boot
  }
  validate_bool($run_at_boot_bool)

  if type($is_puppet_master) == 'String' {
    $is_puppet_master_bool = str2bool($is_puppet_master)
  } else {
    $is_puppet_master_bool = $is_puppet_master
  }
  validate_bool($is_puppet_master_bool)

  # env must be set, else fail, since we use it in the puppet_config template
  if ! $env {
    fail('puppet::agent::env must be set')
  }

  if $puppet_masterport != 'UNSET' and is_integer($puppet_masterport) == false {
    fail("puppet::agent::puppet_masterport is set to <${puppet_masterport}>. It should be an integer.")
  }

  if type($stringify_facts) == 'string' {
    $stringify_facts_bool = str2bool($stringify_facts)
  } else {
    $stringify_facts_bool = $stringify_facts
  }
  validate_bool($stringify_facts_bool)

  case $::osfamily {
    'Debian': {
      $default_agent_sysconfig        = '/etc/default/puppet'
      $default_agent_sysconfig_ensure = 'file'
    }
    'RedHat': {
      $default_agent_sysconfig        = '/etc/sysconfig/puppet'
      $default_agent_sysconfig_ensure = 'file'
    }
    'Solaris': {
      $default_agent_sysconfig        = undef
      $default_agent_sysconfig_ensure = 'absent'
    }
    'Suse': {
      $default_agent_sysconfig        = '/etc/sysconfig/puppet'
      $default_agent_sysconfig_ensure = 'file'
    }
    default: {
      fail("puppet::agent supports osfamilies Debian, RedHat, Solaris, and Suse. Detected osfamily is <${::osfamily}>.")
    }
  }

  if $agent_sysconfig == 'USE_DEFAULTS' {
    $agent_sysconfig_real = $default_agent_sysconfig
  } else {
    $agent_sysconfig_real = $agent_sysconfig
  }

  if $agent_sysconfig_ensure == 'USE_DEFAULTS' {
    $agent_sysconfig_ensure_real = $default_agent_sysconfig_ensure
  } else {
    $agent_sysconfig_ensure_real = $agent_sysconfig_ensure
  }

  if $is_puppet_master_bool == false {
    $config_content = template('puppet/puppetagent.conf.erb')
  } else {
    $config_content = undef
  }

  case $run_method {
    'service': {
      $daemon_ensure    = 'running'
      $daemon_enable    = true
      $cron_ensure      = 'absent'
      $my_cron_command  = undef
      $cron_user        = undef
      $cron_hour        = undef
      $cron_minute      = undef
    }
    'cron': {
      $daemon_ensure = 'stopped'
      $daemon_enable = false
      $cron_run_one  = fqdn_rand($run_interval)
      $cron_run_two  = fqdn_rand($run_interval) + 30
      $cron_ensure   = 'present'
      $cron_user     = 'root'
      $cron_hour     = '*'
      $cron_minute   = [$cron_run_one, $cron_run_two]

      if $run_in_noop_bool == true {
        $my_cron_command = "${cron_command} --noop"
      } else {
        $my_cron_command = $cron_command
      }
    }
    'disable': {
      $daemon_ensure    = 'stopped'
      $daemon_enable    = false
      $cron_ensure      = 'absent'
      $my_cron_command  = undef
      $cron_user        = undef
      $cron_hour        = undef
      $cron_minute      = undef
    }
    default: {
      fail("puppet::agent::run_method is ${run_method} and must be 'disable', 'service' or 'cron'.")
    }
  }

  if $run_at_boot_bool == true {
    $at_boot_ensure = 'present'
  } else {
    $at_boot_ensure = 'absent'
  }

  if type($symlink_puppet_binary) == 'string' {
    $symlink_puppet_binary_bool = str2bool($symlink_puppet_binary)
  } else {
    $symlink_puppet_binary_bool = $symlink_puppet_binary
  }
  validate_bool($symlink_puppet_binary_bool)

  # optionally create symlinks to puppet binary
  if $symlink_puppet_binary_bool == true {

    # validate params
    validate_absolute_path($symlink_puppet_binary_target)
    validate_absolute_path($puppet_binary)

    file { 'puppet_symlink':
      ensure => link,
      path   => $symlink_puppet_binary_target,
      target => $puppet_binary,
    }
  }

  file { 'puppet_config':
    path    => $config_path,
    content => $config_content,
    owner   => $config_owner,
    group   => $config_group,
    mode    => $config_mode,
  }

  if $default_agent_sysconfig_ensure =~ /(present)|(file)/ {
    file { 'puppet_agent_sysconfig':
      ensure  => $agent_sysconfig_ensure_real,
      path    => $agent_sysconfig_real,
      content => template('puppet/agent_sysconfig.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
    }
  }

  service { 'puppet_agent_daemon':
    # GH: This service will always show as being running while an agent run is
    # taking place, so we no longer ensure its status. Before doing this, there
    # would *always* be a logged change and the Console could never be green.
    #ensure     => $daemon_ensure,
    name       => $daemon_name,
    enable     => $daemon_enable,
  }

  cron { 'puppet_agent':
    ensure  => $cron_ensure,
    command => $my_cron_command,
    user    => $cron_user,
    hour    => $cron_hour,
    minute  => $cron_minute,
  }

  if $run_method == 'cron' {
    cron { 'puppet_agent_once_at_boot':
      ensure  => $at_boot_ensure,
      command => $my_cron_command,
      user    => $cron_user,
      special => 'reboot',
    }
  }
}
