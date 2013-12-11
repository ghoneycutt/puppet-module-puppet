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
  $puppet_ca_server             = 'UNSET',
  $is_puppet_master             = 'false',
  $run_method                   = 'service',
  $run_interval                 = '30',
  $run_in_noop                  = 'false',
  $cron_command                 = '/usr/bin/puppet agent --onetime --ignorecache --no-daemonize --no-usecacheonfailure --detailed-exitcodes --no-splay',
  $run_at_boot                  = 'true',
  $puppet_binary                = '/usr/bin/puppet',
  $symlink_puppet_binary_target = '/usr/local/bin/puppet',
  $symlink_puppet_binary        = 'false',
  $agent_sysconfig              = 'USE_DEFAULTS',
  $agent_sysconfig_ensure       = 'USE_DEFAULTS',
  $daemon_name                  = 'puppet',
) {

  # env must be set, else fail, since we use it in the puppet_config template
  if ! $env {
    fail('puppet::agent::env must be set')
  }

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

  case $is_puppet_master {
    'true': {
      $config_content = undef
    }
    'false': {
      $config_content = template('puppet/puppetagent.conf.erb')
    }
    default: {
      fail("puppet::agent::is_puppet_master must be 'true' or 'false' and is ${is_puppet_master}")
    }
  }

  case $run_method {
    'service': {
      $daemon_ensure = 'running'
      $daemon_enable = true
      $cron_ensure   = 'absent'
      $my_cron_command  = undef
      $cron_user     = undef
      $cron_hour     = undef
      $cron_minute   = undef
    }
    'cron': {
      $daemon_ensure = 'stopped'
      $daemon_enable = false
      $cron_run_one = fqdn_rand($run_interval)
      $cron_run_two = fqdn_rand($run_interval) + 30
      $cron_ensure   = 'present'
      case $run_in_noop {
        'true': {
          $my_cron_command = "${cron_command} --noop"
        }
        'false': {
          $my_cron_command = $cron_command
        }
        default: {
          fail("run_in_noop is ${run_in_noop} must be 'true' or 'false'.")
        }
      }
      $cron_user     = 'root'
      $cron_hour     = '*'
      $cron_minute   = [$cron_run_one, $cron_run_two]
    }
    default: {
      fail("puppet::agent::run_method is ${run_method} and must be 'service' or 'cron'.")
    }
  }

  case $run_at_boot {
    'true': {
      $at_boot_ensure = 'present'
    }
    'false': {
      $at_boot_ensure = 'absent'
    }
    default: {
      fail("puppet::agent::run_at_boot is ${run_at_boot} and must be 'true' or 'false'.")
    }
  }

  if type($symlink_puppet_binary) == 'string' {
    $symlink_puppet_binary_real = str2bool($symlink_puppet_binary)
  } else {
    $symlink_puppet_binary_real = $symlink_puppet_binary
  }

  # optionally create symlinks to puppet binary
  if $symlink_puppet_binary_real == true {

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
