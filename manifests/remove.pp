# == Class: nx::remove
#
# Remove NX installation
#
class nx::remove {

  package { ['nxclient', 'nxnode', 'nxserver'] :
    ensure => absent,
  }

  file { '/usr/NX' :
    ensure  => absent,
    purge   => true,
    recurse => true,
    force   => true,
  }

  user { 'nx' :
    ensure => absent,
  }

  Package['nxserver'] -> Package['nxnode'] -> Package['nxclient']
    -> User['nx'] -> File['/usr/NX']
}
