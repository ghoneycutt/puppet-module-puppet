# == Class: puppet::master::maintenance
#
class puppet::master::maintenance (
  $clientbucket_path          = '/var/lib/puppet/clientbucket/',
  $clientbucket_days_to_keep  = '30',
  $filebucket_cleanup_command = '/usr/bin/find /var/lib/puppet/clientbucket/ -type f -mtime +30 -exec /bin/rm -fr {} \;',
  $filebucket_cleanup_user    = 'root',
  $filebucket_cleanup_hour    = '0',
  $filebucket_cleanup_minute  = '0',
  $reportdir                   = $::puppet_reportdir,
  $reportdir_days_to_keep      = '30',
  $reportdir_purge_command     = '/usr/bin/find /var/lib/puppet/reports -type f -mtime +30 -exec /bin/rm -fr {} \;',
  $reportdir_purge_user        = 'root',
  $reportdir_purge_hour        = '0',
  $reportdir_purge_minute      = '15',
) {

  validate_absolute_path($reportdir)

  # if not using the defaults, then construct the command with variables, else
  # use the default command
  if ( $clientbucket_days_to_keep != 30 ) or ( $clientbucket_path != '/var/lib/puppet/clientbucket/' ) {
    $my_filebucket_cleanup_command = "/usr/bin/find ${clientbucket_path} -type f -mtime +${clientbucket_days_to_keep} -exec /bin/rm -fr {} \\;"
  } else {
    $my_filebucket_cleanup_command = $filebucket_cleanup_command
  }

  cron { 'filebucket_cleanup':
    ensure  => present,
    command => $my_filebucket_cleanup_command,
    user    => $filebucket_cleanup_user,
    hour    => $filebucket_cleanup_hour,
    minute  => $filebucket_cleanup_minute,
  }

  if $reportdir_days_to_keep <= '0' {
    fail("puppet::master::maintenance::reportdir_days_to_keep must be a positive integer greater than zero. Detected value is <${reportdir_days_to_keep}>.")
  }

  if ( $reportdir_days_to_keep != 30 ) or ( $reportdir != '/var/lib/puppet/reports' ) {
    $my_reportdir_purge_command = "/usr/bin/find ${reportdir} -type f -mtime +${reportdir_days_to_keep} -exec /bin/rm -fr {} \\;"
  } else {
    $my_reportdir_purge_command = $reportdir_purge_command
  }

  cron { 'purge_old_puppet_reports':
    ensure  => present,
    command => $my_reportdir_purge_command,
    user    => $reportdir_purge_user,
    hour    => $reportdir_purge_hour,
    minute  => $reportdir_purge_minute,
  }
}
