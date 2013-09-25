require 'spec_helper'

describe 'nx' do
  context 'default options should ensure NX is installed and configured' do
    let(:facts) { {
      :fqdn            => 'testhost.example.com',
      :osfamily        => 'RedHat',
      :operatingsystem => 'RedHat',
    } }

    it {
      # nx::init.pp
      should include_class('nx')
      should include_class('nx::install')
      should include_class('nx::config')

      # nx::install.pp
      should contain_package('nxclient').with_ensure('installed')
      should contain_package('nxnode').with_ensure('installed')
      should contain_package('nxserver').with_ensure('installed')

      # nx::config.pp
      should contain_file('/usr/NX/etc/node.cfg') \
        .with_content(/^NodeName = "testhost.example.com"/)
      should contain_file('/usr/NX/etc/node.cfg') \
        .with_content(/^CommandStartGnome = "\/etc\/gdm\/Xsession gnome-session"$/)
      should contain_file('/usr/NX/etc/node.cfg') \
        .with_content(/^CommandStartKDE = "\/etc\/kde\/kdm\/Xsession startkde"$/)
      should contain_file('/usr/NX/etc/node.cfg') \
        .with_content(/^CommandStartCDE = "\/usr\/bin\/dbus-launch --exit-with-session xfce4-session"/)

      should contain_file('/usr/NX/etc/node.lic').with({
        'owner' => 'root',
        'group' => 'root',
        'mode'  => '0400',
      })
      should contain_file('/usr/NX/etc/node.lic').with({
        'owner' => 'root',
        'group' => 'root',
        'mode'  => '0400',
      })

    }
  end

  context 'ensure absent should remove NX' do
    let(:params) { { 'ensure' => 'absent' } }
    it {
      should include_class('nx::remove')

      # nx::remove.pp
      should contain_package('nxclient').with_ensure('absent')
      should contain_package('nxnode').with_ensure('absent')
      should contain_package('nxserver').with_ensure('absent')
    }
  end
end
