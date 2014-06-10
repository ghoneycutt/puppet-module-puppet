# == Define: puppet::mkdir_p
#
# Provide `mkdir -p` functionality for a directory
#
# Idea is to use this mkdir_p in conjunction with a file resource
#
# Example usage:
#
# puppet::mkdir_p { '/some/dir/structure': }
#
# file { '/some/dir/structure':
#   ensure  => directory,
#   require => Puppet::Mkdir_p['/some/dir/structure'],
# }
#
define puppet::mkdir_p () {

  validate_absolute_path($name)

  exec { "mkdir_p-${name}":
    command => "mkdir -p ${name}",
    unless  => "test -d ${name}",
    path    => '/bin:/usr/bin',
  }
}
