# == Class: puppet::lint
#
# Manage puppet-lint - http://github.com/rodjek/puppet-lint
#
class puppet::lint (
  $ensure       = 'present',
  $provider     = 'gem',
  $version      = undef,
  $lint_args    = '--no-80chars-check',
  $lintrc_path  = "${::root_home}/.puppet-lint.rc",
  $lintrc_owner = 'root',
  $lintrc_group = 'root',
  $lintrc_mode  = '0644',
) {

  if $version {
    $my_ensure = $version
  }

  package { 'puppet-lint':
    ensure   => $my_ensure,
    provider => $provider,
  }

  file { $lintrc_path:
    ensure  => file,
    content => "${lint_args}\n",
    owner   => $lintrc_owner,
    group   => $lintrc_group,
    mode    => $lintrc_mode,
  }
}
