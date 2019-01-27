# Change Log

## [v3.2.1](https://github.com/ghoneycutt/puppet-module-puppet/tree/v3.2.1)

[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v3.2.0...v3.2.1)

**Closed issues:**

- ignorecache setting in $cron\_command let newer Puppet agent fail [\#141](https://github.com/ghoneycutt/puppet-module-puppet/issues/141)
- Is dependency on puppetlabs-inifile still necessary? [\#139](https://github.com/ghoneycutt/puppet-module-puppet/issues/139)

**Merged pull requests:**

- Fix $cron\_command [\#142](https://github.com/ghoneycutt/puppet-module-puppet/pull/142) ([Phil-Friderici](https://github.com/Phil-Friderici))
- \(Maint\) CI testing - Allow newest hiera gem [\#134](https://github.com/ghoneycutt/puppet-module-puppet/pull/134) ([ghoneycutt](https://github.com/ghoneycutt))

## [v3.2.0](https://github.com/ghoneycutt/puppet-module-puppet/tree/v3.2.0) (2017-06-05)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.20.1...v3.2.0)

**Merged pull requests:**

- Remove deprecated params [\#132](https://github.com/ghoneycutt/puppet-module-puppet/pull/132) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.20.1](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.20.1) (2017-03-29)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.20.0...v2.20.1)

## [v2.20.0](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.20.0) (2017-03-29)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v3.1.0...v2.20.0)

**Merged pull requests:**

- Add ability to specify configtimeout option in the agent config [\#131](https://github.com/ghoneycutt/puppet-module-puppet/pull/131) ([ghoneycutt](https://github.com/ghoneycutt))

## [v3.1.0](https://github.com/ghoneycutt/puppet-module-puppet/tree/v3.1.0) (2017-01-23)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v3.0.2...v3.1.0)

**Merged pull requests:**

- Add parameter env [\#130](https://github.com/ghoneycutt/puppet-module-puppet/pull/130) ([ghoneycutt](https://github.com/ghoneycutt))

## [v3.0.2](https://github.com/ghoneycutt/puppet-module-puppet/tree/v3.0.2) (2017-01-11)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v3.0.1...v3.0.2)

**Closed issues:**

- Why is running as a service no longer an option? [\#125](https://github.com/ghoneycutt/puppet-module-puppet/issues/125)

**Merged pull requests:**

- Puppetserver sysconfig [\#128](https://github.com/ghoneycutt/puppet-module-puppet/pull/128) ([ghoneycutt](https://github.com/ghoneycutt))
- Fix gem dependencies for testing [\#127](https://github.com/ghoneycutt/puppet-module-puppet/pull/127) ([ghoneycutt](https://github.com/ghoneycutt))

## [v3.0.1](https://github.com/ghoneycutt/puppet-module-puppet/tree/v3.0.1) (2016-11-02)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v3.0.0...v3.0.1)

**Merged pull requests:**

- Add rubocop testing and conform to its style recommendations [\#124](https://github.com/ghoneycutt/puppet-module-puppet/pull/124) ([ghoneycutt](https://github.com/ghoneycutt))
- Add rake task for github\_changelog\_generator [\#123](https://github.com/ghoneycutt/puppet-module-puppet/pull/123) ([ghoneycutt](https://github.com/ghoneycutt))
- Support puppet v4.8.0 [\#122](https://github.com/ghoneycutt/puppet-module-puppet/pull/122) ([ghoneycutt](https://github.com/ghoneycutt))

## [v3.0.0](https://github.com/ghoneycutt/puppet-module-puppet/tree/v3.0.0) (2016-11-02)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.19.0...v3.0.0)

**Closed issues:**

- Add support for manifest ordering for agent [\#71](https://github.com/ghoneycutt/puppet-module-puppet/issues/71)
- Module doesn't seen to ensure service is running [\#46](https://github.com/ghoneycutt/puppet-module-puppet/issues/46)

**Merged pull requests:**

- Release v3.0.0 - Transition to Puppet v4 [\#121](https://github.com/ghoneycutt/puppet-module-puppet/pull/121) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.19.0](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.19.0) (2016-07-13)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.18.1...v2.19.0)

**Merged pull requests:**

- Puppetv4 agent [\#119](https://github.com/ghoneycutt/puppet-module-puppet/pull/119) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.18.1](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.18.1) (2016-07-12)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.18.0...v2.18.1)

**Merged pull requests:**

- Fix testing [\#120](https://github.com/ghoneycutt/puppet-module-puppet/pull/120) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.18.0](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.18.0) (2016-04-29)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.17.1...v2.18.0)

**Merged pull requests:**

- Dont recursively cleanup master maintenance [\#118](https://github.com/ghoneycutt/puppet-module-puppet/pull/118) ([ghoneycutt](https://github.com/ghoneycutt))
- Allow configuration of the number of max requests handled per puppet … [\#114](https://github.com/ghoneycutt/puppet-module-puppet/pull/114) ([dfairhurst](https://github.com/dfairhurst))

## [v2.17.1](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.17.1) (2016-04-28)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.17.0...v2.17.1)

**Merged pull requests:**

- Modernize [\#117](https://github.com/ghoneycutt/puppet-module-puppet/pull/117) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.17.0](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.17.0) (2015-11-25)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.16.0...v2.17.0)

**Closed issues:**

- What's the purpose of $puppet::agent::env? [\#109](https://github.com/ghoneycutt/puppet-module-puppet/issues/109)
- hardcoded maintenance jobs avoids using specific settings [\#101](https://github.com/ghoneycutt/puppet-module-puppet/issues/101)

**Merged pull requests:**

- parameterize ssldir in puppet agent's config [\#113](https://github.com/ghoneycutt/puppet-module-puppet/pull/113) ([Phil-Friderici](https://github.com/Phil-Friderici))
- Fixup metadata [\#112](https://github.com/ghoneycutt/puppet-module-puppet/pull/112) ([ghoneycutt](https://github.com/ghoneycutt))
- Changed outdated type-function to is\_\<type\> [\#111](https://github.com/ghoneycutt/puppet-module-puppet/pull/111) ([Phil-Friderici](https://github.com/Phil-Friderici))

## [v2.16.0](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.16.0) (2015-08-18)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.15.0...v2.16.0)

**Merged pull requests:**

- make hardcoded commands really flexible [\#102](https://github.com/ghoneycutt/puppet-module-puppet/pull/102) ([Phil-Friderici](https://github.com/Phil-Friderici))

## [v2.15.0](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.15.0) (2015-02-20)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/2.14.4...v2.15.0)

**Merged pull requests:**

- Disable master maintenance cronjobs [\#99](https://github.com/ghoneycutt/puppet-module-puppet/pull/99) ([ghoneycutt](https://github.com/ghoneycutt))

## [2.14.4](https://github.com/ghoneycutt/puppet-module-puppet/tree/2.14.4) (2015-02-20)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.14.3...2.14.4)

**Merged pull requests:**

- Support Ruby v2.1.0 [\#98](https://github.com/ghoneycutt/puppet-module-puppet/pull/98) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.14.3](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.14.3) (2015-02-13)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.14.2...v2.14.3)

**Merged pull requests:**

- Improve spec tests for maintenance class [\#96](https://github.com/ghoneycutt/puppet-module-puppet/pull/96) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.14.2](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.14.2) (2014-12-20)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.14.1...v2.14.2)

**Merged pull requests:**

- Travis-ci use containers for faster builds [\#94](https://github.com/ghoneycutt/puppet-module-puppet/pull/94) ([ghoneycutt](https://github.com/ghoneycutt))
- Support run\_interval larger than 30 [\#93](https://github.com/ghoneycutt/puppet-module-puppet/pull/93) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.14.1](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.14.1) (2014-12-10)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.14.0...v2.14.1)

**Closed issues:**

- Default reportdir\_purge\_command does not work [\#73](https://github.com/ghoneycutt/puppet-module-puppet/issues/73)
- need for specific uid/gid for Puppet user [\#42](https://github.com/ghoneycutt/puppet-module-puppet/issues/42)
- when changing from NOOP to OP old cronjob is not deleted [\#41](https://github.com/ghoneycutt/puppet-module-puppet/issues/41)
- hardcoded cron\_command when run\_in\_noop is active [\#40](https://github.com/ghoneycutt/puppet-module-puppet/issues/40)
- style - puppet::agent has quoted booleans [\#23](https://github.com/ghoneycutt/puppet-module-puppet/issues/23)

**Merged pull requests:**

- Follow symlink for reportdir [\#91](https://github.com/ghoneycutt/puppet-module-puppet/pull/91) ([ghost](https://github.com/ghost))

## [v2.14.0](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.14.0) (2014-11-25)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.13.1...v2.14.0)

**Merged pull requests:**

- Style - Fix indentation of attribute arrows [\#90](https://github.com/ghoneycutt/puppet-module-puppet/pull/90) ([ghoneycutt](https://github.com/ghoneycutt))
- Manage mysql options [\#89](https://github.com/ghoneycutt/puppet-module-puppet/pull/89) ([ghoneycutt](https://github.com/ghoneycutt))
- Fix linebreaks puppetconf [\#86](https://github.com/ghoneycutt/puppet-module-puppet/pull/86) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.13.1](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.13.1) (2014-10-15)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.13.0...v2.13.1)

**Merged pull requests:**

- Disable SSLv3 as it is insecure [\#84](https://github.com/ghoneycutt/puppet-module-puppet/pull/84) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.13.0](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.13.0) (2014-10-09)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.12.0...v2.13.0)

**Merged pull requests:**

- Add parameters for http\_proxy and http\_proxy\_port [\#80](https://github.com/ghoneycutt/puppet-module-puppet/pull/80) ([kytomaki](https://github.com/kytomaki))

## [v2.12.0](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.12.0) (2014-10-06)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.11.3...v2.12.0)

**Merged pull requests:**

- Add support for etckeeper [\#83](https://github.com/ghoneycutt/puppet-module-puppet/pull/83) ([ghoneycutt](https://github.com/ghoneycutt))
- Add masterport to agent config [\#82](https://github.com/ghoneycutt/puppet-module-puppet/pull/82) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.11.3](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.11.3) (2014-10-01)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.11.2...v2.11.3)

**Merged pull requests:**

- V370 [\#77](https://github.com/ghoneycutt/puppet-module-puppet/pull/77) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.11.2](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.11.2) (2014-09-05)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.11.1...v2.11.2)

**Merged pull requests:**

- Metadata [\#76](https://github.com/ghoneycutt/puppet-module-puppet/pull/76) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.11.1](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.11.1) (2014-06-10)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.11.0...v2.11.1)

**Closed issues:**

- Dependency on puppet-module-common  [\#66](https://github.com/ghoneycutt/puppet-module-puppet/issues/66)

**Merged pull requests:**

- Add dependency of ghoneycutt/common to metadata [\#69](https://github.com/ghoneycutt/puppet-module-puppet/pull/69) ([ghoneycutt](https://github.com/ghoneycutt))
- replaced dead links for dashboard [\#68](https://github.com/ghoneycutt/puppet-module-puppet/pull/68) ([aviau](https://github.com/aviau))

## [v2.11.0](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.11.0) (2014-06-03)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.10.0...v2.11.0)

**Merged pull requests:**

- Stringify facts [\#65](https://github.com/ghoneycutt/puppet-module-puppet/pull/65) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.10.0](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.10.0) (2014-06-01)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.9.3...v2.10.0)

**Merged pull requests:**

- Add environment fact [\#64](https://github.com/ghoneycutt/puppet-module-puppet/pull/64) ([ghost](https://github.com/ghost))
- Specify version of apache to use in fixtures [\#61](https://github.com/ghoneycutt/puppet-module-puppet/pull/61) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.9.3](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.9.3) (2014-01-31)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.9.2...v2.9.3)

**Merged pull requests:**

- Support Puppet v3.4 and Ruby v2.0.0 [\#57](https://github.com/ghoneycutt/puppet-module-puppet/pull/57) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.9.2](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.9.2) (2014-01-23)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.9.1...v2.9.2)

**Merged pull requests:**

- Remove Travis work around for ruby v1.8.7 [\#56](https://github.com/ghoneycutt/puppet-module-puppet/pull/56) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.9.1](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.9.1) (2014-01-21)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.9.0...v2.9.1)

**Merged pull requests:**

- Refactor to allow booleans in parameters. [\#55](https://github.com/ghoneycutt/puppet-module-puppet/pull/55) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.9.0](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.9.0) (2014-01-10)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.8.0...v2.9.0)

**Merged pull requests:**

- Add ability to to clean up the reports directory [\#54](https://github.com/ghoneycutt/puppet-module-puppet/pull/54) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.8.0](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.8.0) (2014-01-03)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.7.0...v2.8.0)

**Merged pull requests:**

- Set run method to disable [\#53](https://github.com/ghoneycutt/puppet-module-puppet/pull/53) ([ghoneycutt](https://github.com/ghoneycutt))
- Support rspec-puppet v1.0.0 [\#51](https://github.com/ghoneycutt/puppet-module-puppet/pull/51) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.7.0](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.7.0) (2013-12-06)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.6.1...v2.7.0)

**Merged pull requests:**

- Support Suse 11 [\#49](https://github.com/ghoneycutt/puppet-module-puppet/pull/49) ([ghoneycutt](https://github.com/ghoneycutt))
- Improve spec testing [\#48](https://github.com/ghoneycutt/puppet-module-puppet/pull/48) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.6.1](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.6.1) (2013-11-11)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.5.3...v2.6.1)

**Closed issues:**

- "-":6: bad command when setting up an agent [\#25](https://github.com/ghoneycutt/puppet-module-puppet/issues/25)

**Merged pull requests:**

- Release v2.6.0 - Debian Support [\#39](https://github.com/ghoneycutt/puppet-module-puppet/pull/39) ([ghoneycutt](https://github.com/ghoneycutt))
- Only define Cron\['puppet\_agent\_once\_at\_boot'\] if $run\_method == 'cron' [\#37](https://github.com/ghoneycutt/puppet-module-puppet/pull/37) ([tekenny](https://github.com/tekenny))

## [v2.5.3](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.5.3) (2013-11-10)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.5.2...v2.5.3)

**Merged pull requests:**

- Fix bug with running puppet::master on Debian [\#38](https://github.com/ghoneycutt/puppet-module-puppet/pull/38) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.5.2](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.5.2) (2013-11-08)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.5.1...v2.5.2)

## [v2.5.1](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.5.1) (2013-11-08)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.5.0...v2.5.1)

**Merged pull requests:**

- Update mysql [\#36](https://github.com/ghoneycutt/puppet-module-puppet/pull/36) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.5.0](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.5.0) (2013-11-08)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.4.0...v2.5.0)

**Merged pull requests:**

- Add Support for Solaris to puppet::agent [\#35](https://github.com/ghoneycutt/puppet-module-puppet/pull/35) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.4.0](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.4.0) (2013-11-08)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.3.0...v2.4.0)

**Merged pull requests:**

- Cleanup dashboard reports [\#32](https://github.com/ghoneycutt/puppet-module-puppet/pull/32) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.3.0](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.3.0) (2013-11-08)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.2.0...v2.3.0)

**Merged pull requests:**

- Symlink merge [\#34](https://github.com/ghoneycutt/puppet-module-puppet/pull/34) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.2.0](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.2.0) (2013-11-08)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.1.3...v2.2.0)

**Closed issues:**

- Could not find dependency File\[httpd\_vdir\] [\#29](https://github.com/ghoneycutt/puppet-module-puppet/issues/29)

**Merged pull requests:**

- Refactor spec tests [\#31](https://github.com/ghoneycutt/puppet-module-puppet/pull/31) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.1.3](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.1.3) (2013-09-29)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.1.2...v2.1.3)

## [v2.1.2](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.1.2) (2013-09-27)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.1.1...v2.1.2)

**Closed issues:**

- cron job to dump database has permission error [\#17](https://github.com/ghoneycutt/puppet-module-puppet/issues/17)

**Merged pull requests:**

- Update travis to test syntax validation and lint. [\#24](https://github.com/ghoneycutt/puppet-module-puppet/pull/24) ([ghoneycutt](https://github.com/ghoneycutt))
- Secure dashboard [\#22](https://github.com/ghoneycutt/puppet-module-puppet/pull/22) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.1.1](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.1.1) (2013-09-22)
[Full Changelog](https://github.com/ghoneycutt/puppet-module-puppet/compare/v2.1.0...v2.1.1)

**Closed issues:**

- integrate with travis-ci.org [\#11](https://github.com/ghoneycutt/puppet-module-puppet/issues/11)
- spec tests [\#9](https://github.com/ghoneycutt/puppet-module-puppet/issues/9)

**Merged pull requests:**

- Note needed sudoers entry in README for cron jobs [\#21](https://github.com/ghoneycutt/puppet-module-puppet/pull/21) ([ghoneycutt](https://github.com/ghoneycutt))
- Fix dump\_dashboard\_database and redirect output [\#19](https://github.com/ghoneycutt/puppet-module-puppet/pull/19) ([kentjohansson](https://github.com/kentjohansson))
- Show status of Travis-ci in README [\#16](https://github.com/ghoneycutt/puppet-module-puppet/pull/16) ([ghoneycutt](https://github.com/ghoneycutt))
- Differentiate between Dashboard server and not. [\#15](https://github.com/ghoneycutt/puppet-module-puppet/pull/15) ([ghoneycutt](https://github.com/ghoneycutt))

## [v2.1.0](https://github.com/ghoneycutt/puppet-module-puppet/tree/v2.1.0) (2013-06-14)
**Closed issues:**

- documentation is incomplete [\#10](https://github.com/ghoneycutt/puppet-module-puppet/issues/10)
- puppetmaster service [\#4](https://github.com/ghoneycutt/puppet-module-puppet/issues/4)
- documentation is incomplete [\#3](https://github.com/ghoneycutt/puppet-module-puppet/issues/3)
- is it possible to use git to store puppet conf? [\#1](https://github.com/ghoneycutt/puppet-module-puppet/issues/1)

**Merged pull requests:**

- Add option to use htpasswd for Dashboard. [\#14](https://github.com/ghoneycutt/puppet-module-puppet/pull/14) ([ghoneycutt](https://github.com/ghoneycutt))
- Spec tests [\#13](https://github.com/ghoneycutt/puppet-module-puppet/pull/13) ([kividiot](https://github.com/kividiot))
- Update of documentation [\#12](https://github.com/ghoneycutt/puppet-module-puppet/pull/12) ([kividiot](https://github.com/kividiot))
- Add documentation [\#8](https://github.com/ghoneycutt/puppet-module-puppet/pull/8) ([ghoneycutt](https://github.com/ghoneycutt))
- Ensure puppetmaster service is not started at boot time [\#7](https://github.com/ghoneycutt/puppet-module-puppet/pull/7) ([ghoneycutt](https://github.com/ghoneycutt))
- Removed stopping of puppetmaster [\#6](https://github.com/ghoneycutt/puppet-module-puppet/pull/6) ([MWinther](https://github.com/MWinther))
- Basic documentation [\#5](https://github.com/ghoneycutt/puppet-module-puppet/pull/5) ([MWinther](https://github.com/MWinther))
- Rebirth [\#2](https://github.com/ghoneycutt/puppet-module-puppet/pull/2) ([ghoneycutt](https://github.com/ghoneycutt))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
