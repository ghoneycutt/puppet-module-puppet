# puppet-module-puppet #
===

[![Build Status](https://travis-ci.org/ghoneycutt/puppet-module-puppet.png?branch=secure_dashboard)](https://travis-ci.org/ghoneycutt/puppet-module-puppet)

This module handles the various parts of puppet on a given machine.

Dependencies for this module are: apache, common, mysql and passenger

## Components ##

### Agent
---------
- Manages the puppet agent on a client
- Setup of configuration files
- Setup of service or crontask to run the agent periodically
- Ensure puppet agent is run at boottime

### Master
----------
- Manages apache with passenger
- Setup of config files needed to run master
- Calls the `puppet::lint` class
- Calls the `puppet::master::maintenance` class
- Manages firewall rule for puppet if needed
- Maintenance to purge filebucket and reports

### Dashboard
-------------
- Manages [Puppet Dashboard](https://github.com/sodabrew/puppet-dashboard)
- This installation is used by puppet systems, that need access to the dashboard

### Dashboard Server
--------------------
- Manages [Puppet Dashboard](https://github.com/sodabrew/puppet-dashboard)
- This is the actual server running the Dashboard
- Configures the Dashboard MySQL settings
- Creates database for puppet with mysql module
- Calls the `puppet::dashboard::maintenance` class
- Maintenance to clean up old reports, optimize database and dump database
- For the maintenance cron jobs, you should have the following line in your `/etc/sudoers` which is not managed with this module.
<pre>
Defaults:root !requiretty
</pre>

### Lint
--------
- Manages [puppet-lint](http://github.com/rodjek/puppet-lint)


## Compatibility ##
-------------------
Ruby versions 1.8.7, 1.9.3, 2.0.0 and 2.1.0 on Puppet v3.

### Puppet Master
-----------------
* Debian 6
* Debian 7
* EL 6
* Ubuntu 12.04 LTS

### Puppet Agent
----------------
* Debian 6
* Debian 7
* EL 6
* EL 7
* Solaris
* Suse 11
* Ubuntu 12.04 LTS

===

## Class `puppet::agent` ##

### Parameters ###

certname
--------
The certificate name for the client.

- *Default*: $::fqdn

config_path
-----------
The location of the puppet config file.

- *Default*: /etc/puppet/puppet.conf

config_owner
------------
The owner of the config file.

- *Default*: root

config_group
------------
The group for the config file.

- *Default*: root

config_mode
-----------
The mode for the config file.

- *Default*: 0644

env
---
The selected environment for the client.

- *Default*: $::env

puppet_server
-------------
The puppet server the client should connect to.

- *Default*: puppet

puppet_masterport
-----------------
The masterport setting in puppet.conf. By default this line is not set.

- *Default*: UNSET

puppet_ca_server
----------------
The puppet CA server the client should use

- *Default*: UNSET

http_proxy_host
---------------
The http-proxy the client should use

- *Default*: UNSET

http_proxy_port
----------------
The http-proxy port the client should use

- *Default*: UNSET

is_puppet_master
----------------
Whether the machine is a puppet master or not.

- *Default*: false

run_method
----------
Whether to run as a service or in cron mode. Valid values are `disable`, `cron`, and `service`. The value `disable` disables automatic puppet runs and assumes you are running as a service.

- *Default*: service

run_interval
------------
The interval, in minutes, with which the client should run. If greater than 30, the agent will only run once per hour.

- *Default*: 30

run_in_noop
-----------
Whether the client should run in noop mode or not.

- *Default*: false

cron_command
------------
The command that should be added to the crontab (in cron mode)

- *Default*: /usr/bin/puppet agent --onetime --ignorecache --no-daemonize --no-usecacheonfailure --detailed-exitcodes --no-splay

run_at_boot
-----------
Whether the client should run right after boot

- *Default*: true

puppet_binary
-------------
Path to puppet binary to create symlink from

- *Default*: '/usr/bin/puppet'

symlink_puppet_binary_target
----------------------------
Path to where the symlink should be created

- *Default*: '/usr/local/bin/puppet'

symlink_puppet_binary
---------------------
Boolean for ensuring a symlink for puppet_binary to symlink_puppet_binary_target. This is useful if you install puppet in a non-standard location that is not in your $PATH.

- *Default*: false

agent_sysconfig
---------------
The location of puppet agent sysconfig file.

- *Default*: use defaults based on osfamily

agent_sysconfig_ensure
----------------------
String for 'file' or 'present'. Allows you to not manage the sysconfig file.

- *Default*: use defaults based on osfamily

daemon_name
-----------
The name the puppet agent daemon should run as.

- *Default*: puppet

ssldir
------
String with absolute path for ssldir in puppet agent's config. Using the default will set it to: '$vardir/ssl'

- *Default*: 'USE_DEFAULTS'

stringify_facts
---------------
Boolean to set the value of stringify_facts main section of the puppet agent's config. This must be set to true to use structured facts.

- *Default*: true

etckeeper_hooks
---------------
Boolean to include pre- and postrun hooks for etckeeper in the main section of the puppet agent's config.

- *Default*: false

===

## Class `puppet::dashboard` ##

### Parameters ###

dashboard_package
-----------------
String or Array of the dashboard package(s) name.

- *Default*: 'puppet-dashboard'

dashboard_user
--------------
The user for dashboard installation.

- *Default*: use defaults based on osfamily

dashboard_group
--------------
The group for dashboard installation.

- *Default*: use defaults based on osfamily

sysconfig_path
-------------------
The location of puppet dashboard sysconfig file.

- *Default*: use defaults based on osfamily

external_node_script_path
-------------------------
The script to call from puppet to get manifests from dashboard.

- *Default*: /usr/share/puppet-dashboard/bin/external_node

dashboard_fqdn
--------------
The dashboard server FQDN.

- *Default*: puppet.${::domain}

port
----
The port the web server will respond to.

- *Default*: 3000

manage_mysql_options
--------------------
Boolean to use modules default mysql::server settings (mysql_max_packet_size).
For specific mysql::server settings you can use hiera now:
<pre>
puppet::dashboard::server::manage_mysql_options: false
mysql::server::override_options:
  mysqld:
    max_allowed_packet:      '32M'
    innodb_buffer_pool_size: '64M'
</pre>

- *Default*: true

===

## Class `puppet::dashboard::server` ##

### Usage ###
You can optionally specify a hash of htpasswd entries in Hiera.

<pre>
---
puppet::dashboard::htpasswd:
  admin:
    cryptpasswd: $apr1$kVPL28B8$1LggacK2dvrOf4SkOCxyO0
  puppet:
    cryptpasswd: $apr1$F2redFE9$FCyxK2cJuHXphfeQugXBi1
</pre>

### Parameters ###

dashboard_workers
-----------------
Number of dashboard workers to start. Only used on osfamily Debian.

- *Default*: $::processorcount

database_config_path
--------------------
The path to the database config file.

- *Default*: /usr/share/puppet-dashboard/config/database.yml

database_config_owner
---------------------
The owner of the database config file.

- *Default*: puppet-dashboard

database_config_group
---------------------
The database config file group.

- *Default*: puppet-dashboard

database_config_mode
--------------------
The database config file mode.

- *Default*: 0640

htpasswd
--------
Hash of htpasswd entries. See leinaddm/htpasswd module for more information. Only used if security is set to 'htpasswd'.

- *Default*: undef

htpasswd_path
-------------
String of path to htpasswd file to be used by Dashboard. Only used if security is set to 'htpasswd'.

- *Default*: `/etc/puppet/dashboard.htpasswd`

htpasswd_owner
--------------
Owner of htpasswd file.

- *Default*: root

htpasswd_group
--------------
Group of htpasswd file.

- *Default*: use defaults based on osfamily

htpasswd_mode
-------------
Mode of htpasswd file.

- *Default*: 0640

log_dir
-------
The location for the puppet log files.

- *Default*: /var/log/puppet

mysql_user
----------
The user for the mysql connection.

- *Default*: dashboard

mysql_password
--------------
The password for the mysql connection.

- *Default*: puppet

mysql_max_packet_size
---------------------
The mysql max packet size.

- *Default*: 32M

security
--------
String to indicate security type used. Valid values are 'none' and 'htpasswd'. Using 'htpasswd' will use Apache basic auth with a htpasswd file. See htpasswd and htpasswd_path parameters.

- *Default*: 'none'

vhost_path
----------
The location of puppet dashboard vhost file for apache.

- *Default*: use defaults based on osfamily

===

## Class `puppet::dashboard::maintenance` ##

### Parameters ###

db_optimization_command
-----------------------
The command to run to optimize the db.

- *Default*: /usr/bin/rake -f /usr/share/puppet-dashboard/Rakefile RAILS_ENV=production db:raw:optimize >> /var/log/puppet/dashboard_maintenance.log

db_optimization_user
--------------------
The user to run db optimization.

- *Default*: root

db_optimization_hour
--------------------
The hour on which to run db optimization.

- *Default*: 0

db_optimization_minute
----------------------
The minute at which to run db optimization.

- *Default*: 0

db_optimization_monthday
------------------------
The day of the month on which to run db optimization.

- *Default*: 1

reports_days_to_keep
--------------------
How many days to keep the reports.

- *Default*: 30

purge_old_reports_command
-------------------------
Which command to run to purge old reports.
Defaults to: '/usr/bin/rake -f /usr/share/puppet-dashboard/Rakefile RAILS_ENV=production reports:prune upto=${reports_days_to_keep} unit=day >> /var/log/puppet/dashboard_maintenance.log'
If using a specific command here, please keep in mind you need to align it with $reports_days_to_keep yourself.

- *Default*: 'USE_DEFAULTS'


purge_old_reports_user
----------------------
User to purge reports as.

- *Default*: root

purge_old_reports_hour
----------------------
On which hour to purge old reports.

- *Default*: 0

purge_old_reports_minute
------------------------
At which minute to purge old reports.

- *Default*: 30

remove_old_reports_spool
------------------------
Whether we should remove old dashboard reports that have not been imported

- *Default*: 'True'

reports_spool_dir
-----------------
Path to reports in dashboard spool

- *Default*: '/usr/share/puppet-dashboard/spool'

reports_spool_days_to_keep
--------------------------
How many days to keep the unimported reports.

remove_reports_spool_user
-------------------------
User to remove unimported reports.

- *Default*: root

remove_reports_spool_hour
-------------------------
On which hour to remove unimported reports.

- *Default*: 0

remove_reports_spool_minute
---------------------------
At which minute to remove unimported reports

- *Default*: 45

dump_dir
--------
The directory to use for dumps.

- *Default*: /var/local

dump_database_command
---------------------
The command to run to dump the database.
Defaults to: 'cd ~puppet-dashboard && sudo -u ${puppet::dashboard::dashboard_user_real} /usr/bin/rake -f /usr/share/puppet-dashboard/Rakefile RAILS_ENV=production FILE=${dump_dir}/dashboard-`date -I`.sql db:raw:dump >> /var/log/puppet/dashboard_maintenance.log 2>&1 && bzip2 -v9 ${dump_dir}/dashboard-`date -I`.sql >> /var/log/puppet/dashboard_maintenance.log 2>&1'
If using a specific command here, please keep in mind you need to align it with $puppet::dashboard::dashboard_user & $dump_dir yourself.

- *Default*: 'USE_DEFAULTS'

dump_database_user
------------------
User to dump database as.

- *Default*: root

dump_database_hour
------------------
On which hour to dump database.

- *Default*: 1

dump_database_minute
--------------------
At which minute to purge old reports.

- *Default*: 0

days_to_keep_backups
--------------------
Number of days to keep database backups.

- *Default*: 7

purge_old_db_backups_user
-------------------------
User to purge old database dumps as.

- *Default*: root

purge_old_db_backups_hour
-------------------------
On which hour to purge old database dumps.

- *Default*: 2

purge_old_db_backups_minute
---------------------------
At which minute to purge old database dumps.

- *Default*: 0

===

## Class `puppet::lint` ##

### Parameters ###

ensure
------
Whether to install lint.

- *Default*: present

provider
--------
Which provider should supply lint.

- *Default*: gem

version
-------
If you do not want to use the default version of lint, specify which version you want to use here.

- *Default*: undef

lint_args
---------
Which args should be added to the .puppet-lint.rc file

- *Default*: --no-80chars-check

lintrc_path
-----------
The full path to the lint config file.

- *Default*: ${::root_home}/.puppet-lint.rc

lintrc_owner
------------
The owner of the lint config file.

- *Default*: root

lintrc_group
------------
The group of the lint config file.

- *Default*: root

lintrc_mode
-----------
The mode of the lint config file.

- *Default*: 0644

===

## Class `puppet::master` ##

### Usage ###

In Hiera you will need to specify the following.

<pre>
puppet::agent::is_puppet_master: 'true'
</pre>

### Parameters ###

sysconfig_path
--------------
The location of puppet master sysconfig file.

- *Default*: use defaults based on osfamily

vhost_path
----------
The location of puppet master vhost file for apache.

- *Default*: use defaults based on osfamily

rack_dir
--------
The rack directory path.

- *Default*: /usr/share/puppet/rack/puppetmasterd

puppet_user
-----------
The user the puppet master should run as.

- *Default*: puppet

manage_firewall
---------------
Whether to manage the firewall settings on the client

- *Default*: undef

===

## Class `puppet::master::maintenance` ##

If you have a cluster of puppet masters mounting the same data, you should
disable these cronjobs on all systems except for one to ensure they are not all
cleaning up the same data.

```
puppet::master::maintenance::clientbucket_cleanup_ensure: 'absent'
puppet::master::maintenance::reportdir_purge_ensure: 'absent'
```

### Parameters ###

clientbucket_cleanup_ensure
---------------------------
String for ensure parameter for filebucket_cleanup cron job.

- *Default*: 'present'

clientbucket_path
-----------------
Path to where the clientbucket files are stored.

- *Default*: /var/lib/puppet/clientbucket

clientbucket_days_to_keep
-------------------------
The number of days to keep clientbuckets

- *Default*: 30

filebucket_cleanup_command
--------------------------
Command used to cleanup the clientbuckets.

- *Default*: /usr/bin/find ${clientbucket_path} -type f -mtime +30 -exec /bin/rm -fr {} \;

filebucket_cleanup_user
-----------------------
User to run the clientbucket cleanup as.

- *Default*: root

filebucket_cleanup_hour
-----------------------
Hour on which to run the filebucket cleanup.

- *Default*: 0

filebucket_cleanup_minute
-------------------------
Minute at which to run the filebucket cleanup.

- *Default*: 0

reportdir_purge_ensure
----------------------
String for ensure parameter for purge_old_puppet_reports cron job.

- *Default*: 'present'

reportdir
---------
Directory that holds the reports. `$::puppet_reportdir` is a custom fact that reads the `reportdir` setting from Puppet's configuration. This is likely `/var/lib/puppet/reports/`.

- *Default*: $::puppet_reportdir

reportdir_days_to_key
---------------------
String for number of days of reports to keep. Must be a positive integer > 0.

- *Default*: '30'

reportdir_purge_command
-----------------------
Command ran by cron to purge old reports.

- *Default*: /usr/bin/find -L /var/lib/puppet/reports -type f -mtime +30 -exec /bin/rm -fr {} \;'

reportdir_purge_user
--------------------
User for the crontab entry to run the reportdir_purge_command.

- *Default*: root

reportdir_purge_hour
--------------------
Hour at which to run the reportdir_purge_command.

- *Default*: 0

reportdir_purge_minute
----------------------
Minute past the hour in which to run the reportdir_purge_command.

- *Default*: 15
