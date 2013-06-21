# puppet-module-puppet #
===

This module handles the various parts of puppet on a given machine.

Dependencies for this module are: apache, common, mysql and passenger

Agent
-----
- Manages the puppet agent on a client
- Setup of configuration files
- Setup of service or crontask to run the agent periodically
- Ensure puppet agent is run at boottime

Master
------
- Manages apache with passenger
- Setup of config files needed to run master
- Calls the `puppet::lint` class
- Calls the `puppet::master::maintenance` class
- Manages firewall rule for puppet if needed
- Maintenance to cleanup Client bucket files

Dashboard
---------
- Manages [Puppet Dashboard](https://puppetlabs.com/puppet/related-projects/dashboard/)
- This installation is used by puppet systems, that need access to the dashboard

Dashboard Server
----------------
- Manages [Puppet Dashboard](https://puppetlabs.com/puppet/related-projects/dashboard/)
- This is the actual server running the Dashboard
- Configures the Dashboard MySQL settings
- Creates database for puppet with mysql module
- Calls the `puppet::dashboard::maintenance` class
- Maintenance to clean up old reports, optimize database and dump database

Lint
----
- Manages [puppet-lint](http://github.com/rodjek/puppet-lint)

Compatibility
-------------

* EL 6

===

## Parameters for class `puppet::agent` ##

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

puppet_ca_server
----------------
The puppet CA server the client should use

- *Default*: UNSET

is_puppet_master
----------------
Whether the machine is a puppet master or not.

- *Default*: false

run_method
----------
Whether to run as a service or in cron mode.

- *Default*: service

run_interval
------------
The interval with which the client should run (in minutes)

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

agent_sysconfig
---------------
The location of the /etc/sysconfig/puppet file.

- *Default*: /etc/sysconfig/puppet

daemon_name
-----------
The name the puppet agent daemon should run as.

- *Default*: puppet

===

## class `puppet::dashboard` ##

### Parameters ###

dashboard_package
-----------------
The dashboard package name.

- *Default*: puppet-dashboard

dashboard_user
--------------
The user for dashboard installation.

- *Default*: puppet-dashboard

dashboard_group
--------------
The group for dashboard installation.

- *Default*: puppet-dashboard

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

===

## Parameters for class `puppet::dashboard::server` ##

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

===

## Parameters for class `puppet::dashboard::maintenance` ##

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

- *Default*: /usr/bin/rake -f /usr/share/puppet-dashboard/Rakefile RAILS_ENV=production reports:prune upto=30 unit=day >> /var/log/puppet/dashboard_maintenance.log

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

dump_dir
--------
The directory to use for dumps.

- *Default*: /var/local

dump_database_command
---------------------
The command to run to dump the database.

- *Default*: sudo -u puppet-dashboard /usr/bin/rake -f /usr/share/puppet-dashboard/Rakefile RAILS_ENV=production FILE=/var/local/dashboard-`date -I`.sql db:raw:dump >> /var/log/puppet/dashboard_maintenance.log && bzip2 -v9 /var/local/dashboard-`date -I`.sql >> /var/log/puppet/dashboard_maintenance.log

dump_database_user
----------------------
User to dump database as.

- *Default*: root

dump_database_hour
----------------------
On which hour to dump database.

- *Default*: 1

dump_database_minute
------------------------
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
------------------------
At which minute to purge old database dumps.

- *Default*: 0

===

## Parameters for class `puppet::lint` ##

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
If you do not want to use the default version of lint, specify which 
version you want to use here.

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

## Parameters for class `puppet::master` ##

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

## Parameters for class `puppet::master::maintenance` ##

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
