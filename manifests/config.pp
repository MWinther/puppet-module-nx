# == Class: nx::config
#
# Configure NX server
#

class nx::config {
  $role = $nx::role
  $server_license = $nx::server_license
  $node_license = $nx::node_license
  $terminate_session_days = $nx::terminate_session_days
  $node_list = $nx::node_list
  $desktop_gnome = $nx::desktop_gnome
  $desktop_kde = $nx::desktop_kde
  $desktop_cde = $nx::desktop_cde

  ##
  # Commands to start a particular X session (Gnome, KDE, Xfce)
  #
  $start_session_cmds = {
    'gnome_session' => $::operatingsystem ? {
      /RedHat/ => '/etc/gdm/Xsession gnome-session',
      default  => '/usr/bin/dbus-launch --exit-with-session gnome-session',
    },
    'kde_session'   => $::operatingsystem ? {
      /RedHat/ => '/etc/kde/kdm/Xsession startkde',
      default  => '/usr/bin/dbus-launch --exit-with-session startkde',
    },
    'xfce_session'  => '/usr/bin/dbus-launch --exit-with-session xfce4-session',
  }

  ###
  # Map client settings to session command (used in template)
  #
  $start_gnome_session = $start_session_cmds[$desktop_gnome]
  $start_kde_session   = $start_session_cmds[$desktop_kde]
  $start_cde_session   = $start_session_cmds[$desktop_cde]

  # Default file permissions
  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  ##
  # Node configuration applicable for all roles
  #
  file { '/usr/NX/etc/node.cfg' :
    ensure  => present,
    content => template('nx/node.cfg.erb'),
  }

  file { '/usr/NX/etc/node.lic' :
    ensure  => present,
    mode    => '0400',
    content => $node_license,
  }

  # FIXME
#  file { '/usr/NX/etc/keys/node.localhost.id_dsa.pub' :
#    ensure  => present,
#    mode    => 0644,
#    owner   => root,
#    group   => root,
#    source  => 'puppet:///modules/nx/node.localhost.id_dsa.pub',
#  }

  # Config specific to the "node" role
  if $role == 'node' {
    user { 'nx' :
      ensure => present,
      home   => '/usr/NX/home/nx',
      shell  => '/bin/false',
    }

    file { '/usr/NX/etc/keys' :
      ensure  => directory,
      owner   => 'nx',
      group   => 'root',
      mode    => '0644',
      require => User['nx'],
    }
  }
  # Config specific to the "server" role
  elsif $role == 'server' {
    add_node { $node_list : }
  }

  ###
  # Server and standalone configuration
  #
  if $role == 'server' or $role == 'standalone' {

    # Cronjob to terminate old suspended sessions
    if $terminate_session_days > 0 {
      file { '/usr/local/bin/nx_term_suspended_sessions.sh' :
        ensure  => present,
        mode    => '0744',
        content => template('nx/nx_term_suspended_sessions.sh.erb'),
      }
      cron { 'nx_term_suspended_sessions' :
        command => 'test -f /usr/local/bin/nx_term_suspended_sessions.sh && /usr/local/bin/nx_term_suspended_sessions.sh',
        hour    => 23,
        user    => 'root',
      }
    } else {
      # Remove terminate-old-sessions cronjob
      cron { 'nx_term_suspended_sessions' :
        ensure => absent,
      }
      file { '/usr/local/bin/nx_term_suspended_sessions.sh' :
        ensure => absent,
      }
    }

    file { '/usr/NX/etc/server.cfg' :
      ensure  => present,
      content => template('nx/server.cfg.erb'),
    }

    file { '/usr/NX/etc/server.lic' :
      ensure  => present,
      mode    => '0400',
      owner   => 'nx',
      group   => 'root',
      content => $server_license,
    }

# FIXME
#    file { '/usr/NX/etc/keys/node.localhost.id_dsa' :
#      ensure  => present,
#      mode    => 0600,
#      owner   => nx,
#      group   => root,
#      source  => 'puppet:///modules/nx/node.localhost.id_dsa',
#    }
  }
}

