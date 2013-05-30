require 'spec_helper'
describe 'puppet::dashboard' do

  describe 'class puppet::dashboard' do

    context 'dashboard package' do
      let(:params) { {:dashboard_package => 'puppet-dashboard' } }
      let(:facts) { {:osfamily => 'redhat',
                     :operatingsystemrelease => '6.4',
                     :ports_file => '/etc/httpd/ports.conf"',
                     :concat_basedir => '/tmp' } }
      it {
        should include_class('puppet::dashboard')
        should contain_package('puppet_dashboard').with({
          'ensure' => 'present',
          'name'   => 'puppet-dashboard',
        })
      }
    end
  end
end
