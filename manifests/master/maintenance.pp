# == Class: puppet::master::maintenance
#
class puppet::master::maintenance (
  $clientbucket_path          = '/var/lib/puppet/clientbucket/',
  $clientbucket_days_to_keep  = '30',
  $filebucket_cleanup_command = '/usr/bin/find /var/lib/puppet/clientbucket/ -type f -mtime +30 -exec /bin/rm -fr {} \;',
  $filebucket_cleanup_user    = 'root',
  $filebucket_cleanup_hour    = '0',
  $filebucket_cleanup_minute  = '0',
) {

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
}
