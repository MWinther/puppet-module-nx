# == Class: nx
#
# Install and configure NoMachine NX
#

class nx(
  $ensure = 'present',
  $role = 'standalone',
  $server_license = undef,
  $node_license = undef,
  $terminate_session_days = 0,
  $desktop_gnome = 'gnome_session',
  $desktop_kde = 'kde_session',
  $desktop_cde = 'xfce_session',
  $node_list = [],
) {
  if $ensure == 'absent' {
    class{'nx::remove': }
  } else {
    # Ensure present
    class{'nx::install': } ->
    class{'nx::config': } ->
    Class['nx']
  }
}
