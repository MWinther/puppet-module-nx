require 'spec_helper'

describe 'nx::add_node' do
  context 'should add node to nodes.db' do
    let(:title) { 'nxnode1.example.com' }

    it {
      should contain_exec('nodeadd-nxnode1.example.com').with({
        'command' => 'nxserver --nodeadd nxnode1.example.com --connection=encrypted',
        'unless'  => "grep 'nxnode1.example.com' /usr/NX/etc/nodes.db",
      })
    }
  end
end
