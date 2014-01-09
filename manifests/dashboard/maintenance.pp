# == Class: puppet::dashboard::maintenance
#
class puppet::dashboard::maintenance (
  $db_optimization_command     = '/usr/bin/rake -f /usr/share/puppet-dashboard/Rakefile RAILS_ENV=production db:raw:optimize >> /var/log/puppet/dashboard_maintenance.log',
  $db_optimization_user        = 'root',
  $db_optimization_hour        = '0',
  $db_optimization_minute      = '0',
  $db_optimization_monthday    = '1',
  $reports_days_to_keep        = '30',
  $purge_old_reports_command   = '/usr/bin/rake -f /usr/share/puppet-dashboard/Rakefile RAILS_ENV=production reports:prune upto=30 unit=day >> /var/log/puppet/dashboard_maintenance.log',
  $purge_old_reports_user      = 'root',
  $purge_old_reports_hour      = '0',
  $purge_old_reports_minute    = '30',
  $remove_old_reports_spool    = 'true',
  $reports_spool_dir           = '/usr/share/puppet-dashboard/spool',
  $reports_spool_days_to_keep  = '7',
  $remove_reports_spool_user   = 'root',
  $remove_reports_spool_hour   = '0',
  $remove_reports_spool_minute = '45',
  $dump_dir                    = '/var/local',
  $dump_database_command       = 'cd ~puppet-dashboard && sudo -u puppet-dashboard /usr/bin/rake -f /usr/share/puppet-dashboard/Rakefile RAILS_ENV=production FILE=/var/local/dashboard-`date -I`.sql db:raw:dump >> /var/log/puppet/dashboard_maintenance.log 2>&1 && bzip2 -v9 /var/local/dashboard-`date -I`.sql >> /var/log/puppet/dashboard_maintenance.log 2>&1',
  $dump_database_user          = 'root',
  $dump_database_hour          = '1',
  $dump_database_minute        = '0',
  $days_to_keep_backups        = '7',
  $purge_old_db_backups_user   = 'root',
  $purge_old_db_backups_hour   = '2',
  $purge_old_db_backups_minute = '0',
) {

  include common
  require 'puppet::dashboard'

  validate_absolute_path($reports_spool_dir)
  validate_absolute_path($dump_dir)

  if $reports_days_to_keep == '30' {
    $my_purge_old_reports_command = $purge_old_reports_command
  } else {
    $my_purge_old_reports_command = "/usr/bin/rake -f /usr/share/puppet-dashboard/Rakefile RAILS_ENV=production reports:prune upto=${reports_days_to_keep} unit=day >> /var/log/puppet/dashboard_maintenance.log"
  }

  if $dump_dir == '/var/local' and $::osfamily == 'RedHat' {
    $my_dump_database_command = $dump_database_command
  } else {
    $my_dump_database_command = "cd ~puppet-dashboard && sudo -u ${puppet::dashboard::dashboard_user_real} /usr/bin/rake -f /usr/share/puppet-dashboard/Rakefile RAILS_ENV=production FILE=${dump_dir}/dashboard-`date -I`.sql db:raw:dump >> /var/log/puppet/dashboard_maintenance.log 2>&1 && bzip2 -v9 ${dump_dir}/dashboard-`date -I`.sql >> /var/log/puppet/dashboard_maintenance.log 2>&1"
  }

  common::mkdir_p { $dump_dir: }

  file { $dump_dir:
    ensure  => directory,
    group   => $puppet::dashboard::dashboard_group_real,
    mode    => '0775',
    require => Common::Mkdir_p[$dump_dir],
  }

  cron { 'monthly_dashboard_database_optimization':
    ensure   => present,
    command  => $db_optimization_command,
    user     => $db_optimization_user,
    hour     => $db_optimization_hour,
    minute   => $db_optimization_minute,
    monthday => $db_optimization_monthday,
  }

  cron { 'purge_old_reports':
    ensure  => present,
    command => $my_purge_old_reports_command,
    user    => $purge_old_reports_user,
    hour    => $purge_old_reports_hour,
    minute  => $purge_old_reports_minute,
  }

  if type($remove_old_reports_spool) == 'string' {
    $enable_remove_old_reports_spool = str2bool($remove_old_reports_spool)
  } else {
    $enable_remove_old_reports_spool = $remove_old_reports_spool
  }
  if $enable_remove_old_reports_spool == true {
    $remove_old_reports_spool_enable = 'present'
  } else {
    $remove_old_reports_spool_enable = 'absent'
  }

  cron { 'remove_old_reports_spool':
    ensure  => $remove_old_reports_spool_enable,
    command => "/bin/find ${reports_spool_dir} -type f -name \"*.yaml\" -mtime +${$reports_spool_days_to_keep } -exec /bin/rm -f {} \\;",
    user    => $remove_reports_spool_user,
    hour    => $remove_reports_spool_hour,
    minute  => $remove_reports_spool_minute,
  }

  cron { 'dump_dashboard_database':
    command => $my_dump_database_command,
    user    => $dump_database_user,
    hour    => $dump_database_hour,
    minute  => $dump_database_minute,
  }

  cron { 'purge_old_db_backups':
    command => "/bin/find ${dump_dir} -type f -mtime +${days_to_keep_backups} -exec /bin/rm -f {} \\;",
    user    => $purge_old_db_backups_user,
    hour    => $purge_old_db_backups_hour,
    minute  => $purge_old_db_backups_minute,
  }
}
