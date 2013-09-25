# == Define: nx::add_node
#
# Add NX node to master's node database
#

define nx::add_node() {
  $node = $name
  exec { "nodeadd-${name}" :
    path    => '/bin:/usr/bin:/usr/NX/bin',
    command => "nxserver --nodeadd ${node} --connection=encrypted",
    require => Package['nxserver'],
    unless  => "grep '${node}' /usr/NX/etc/nodes.db",
  }
}
