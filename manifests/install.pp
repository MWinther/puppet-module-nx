# == Class: nx::install
#
# Install NX packages
#
class nx::install {
  $role = $nx::role

  $packages = $role ? {
    'node'  => ['nxclient', 'nxnode'],
    default => ['nxclient', 'nxnode', 'nxserver'],
  }

  package { $packages :
    ensure => installed,
  }
}
