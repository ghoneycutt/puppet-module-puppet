# Class: puppet::params
#
# This class manages puppet parameters
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class puppet::params  {
  
  $env              = 'production'
  $masterport       = 8140
  $report           = true
  $report_server    = '$server'
  $use_srv_records  = false
  $pluginsync       = true
  $configtimeout    = 120
  $digest_algorithm = 'md5'
  $classfile        = '$statedir/classes.txt'
  $certname         =  $::fqdn
  $server           = 'puppet'
  $graph            = false
  $noop             = false
  $logdir           = '/var/log/puppet'
  $rundir           = '/var/run/puppet'
  $ssldir           = '$confdir/ssl'

}
