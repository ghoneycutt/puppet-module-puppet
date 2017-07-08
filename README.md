# puppet-module-puppet

#### Table of Contents

1. [Module Description](#module-description)
1. [Dependencies](#dependencies)
1. [Compatibility](#compatibility)
1. [Class Descriptions](#class-descriptions)
    * [puppet](#class-puppet)
    * [puppet::server](#class-puppet-server)

# Module description

[![Build Status](https://travis-ci.org/ghoneycutt/puppet-module-puppet.png?branch=master)](https://travis-ci.org/ghoneycutt/puppet-module-puppet)

This module handles the various parts of puppet including the agent and
puppetserver. It is highly opionated and does not seek to manage the
agent and server in all ways that they can be configured and
implemented.

* The agent runs in noop by default. This is the safest way and ensures
  that changes are known by having to specify that you want to run in
  enforcing mode.

* The agent does not run as a service. There is no good reason for
  running the service. Instead cron should be used to better manage how
  and when the agent runs.

* By default the agent will run every thirty minutes from cron and the
  minutes will be randomized using fqdn_rand() so they are consistent
  per host. If you would like a different schedule, this is easily
  disabled by setting `run_every_thirty` to `false`, in which case,
  it is suggested that the schedule by specified in your profile.

* The trusted_node_data option in puppet.conf is set to true.

This module is targeted at Puppet v4. If you need support for Puppet v3,
please see the puppetv3 branch of this module. Which supports the agent,
master (with apache/passenger), Puppet Dashboard and puppet-lint.

To use the agent, use `include ::puppet`.  If the system is also a
puppetserver, use `include ::puppet::server`, which will also manage the
agent.

It uses puppetlabs/inifile to manage the entries in puppet.conf.

# Dependencies

For version ranges, please see metadata.json.

* [puppetlabs/inifile](https://github.com/puppetlabs/puppetlabs-inifile)
* [puppetlabs/stdlib](https://github.com/puppetlabs/puppetlabs-stdlib)

# Compatibility

Puppet v4 with Ruby versions 2.1.9 with the following platforms. Please
consult the CI testing matrix in .travis.yml for more info. If you are
looking for Puppet v3, please see the [puppetv3
branch](https://github.com/ghoneycutt/puppet-module-puppet/tree/puppetv3).

* EL 6

===

# Class Descriptions

## Class `puppet`

### Description

Manages the puppet agent.

A note on types, `Variant[Enum['true', 'false'], Boolean]` means that
boolean `true` and `false` are supported as well as stringified `'true'`
and `'false'`.

### Parameters

---
#### certname (type: String)
The certificate name for the client.

- *Default*: $::fqdn

---
#### run_every_thirty (type: Variant[Enum['true', 'false'], Boolean])
Determines if a cron job to run the puppet agent every thirty minutes
should be present.

- *Default*: true

---
#### run_in_noop (type: Variant[Enum['true', 'false'], Boolean])
Determines if the puppet agent should run in noop mode. This is done by
appending '--noop' to the `cron_command` parameter.

- *Default*: true

---
#### cron_command (type: String)
Command that will be run from cron for the puppet agent.

- *Default*: '/opt/puppetlabs/bin/puppet agent --onetime --ignorecache
  --no-daemonize --no-usecacheonfailure --detailed-exitcodes --no-splay'

---
#### run_at_boot (type: Variant[Enum['true', 'false'], Boolean])
Determine if a cron job should present that will run the puppet agent at
boot time.

- *Default*: true

---
#### config_path (type: String)
The absolute path to the puppet config file.

- *Default*: /etc/puppetlabs/puppet/puppet.conf

---
#### server (type: String)
The name of the puppet server.

- *Default*: 'puppet'

---
#### ca_server (type: String)
The name of the puppet CA server.

- *Default*: 'puppet'

---
#### env (type: String)
Value of environment option in puppet.conf which defaults to the
environment of the current puppet run. By setting this parameter, you
can specify an environment on the command line (`puppet agent -t
--environment foo`) and it will not trigger a change to the puppet.conf.

- *Default*: $environment

---
#### graph (type: Variant[Enum['true', 'false'], Boolean])
Value of the graph option in puppet.conf.

- *Default*: false

---
#### dns_alt_names (type: Optional[String])
Value of the dns_alt_names option in puppet.conf.

- *Default*: undef

---
#### agent_sysconfig_path (type: String)
The absolute path to the puppet agent sysconfig file.

- *Default*: '/etc/sysconfig/puppet'

## Class `puppet::server`

Manages the puppetserver.

---
#### ca (type: Variant[Enum['true', 'false'], Boolean])
Determines if the system is a puppet CA (certificate authority). There
should be only one CA per cluster of puppet masters.

- *Default*: false

---
#### autosign_entries (type: Variant[Array[String, 1], Undef])
Optional array of entries that will be autosigned.

- *Default*: undef

---
#### sysconfig_path (type: String)
The absolute path to the puppetserver sysconfig file.

- *Default*: '/etc/sysconfig/puppetserver'

---
#### memory_size (type: String /^\d+(m|g)$/)
The amount of memory allocated to the puppetserver. This is passed to
the Xms and Xmx arguments for java. It must be a whole number followed
by the unit 'm' for MB or 'g' for GB.

- *Default*: '2g'

---
#### enc (type: Optional[String])
The absolute path to an ENC. If this is set, it will be the value for the
external_nodes option in puppet.conf and the node_terminus option will
be set to 'exec'.

- *Default*: undef
