require 'spec_helper'
describe 'puppet::dashboard' do

  describe 'class puppet::dashboard' do
    context 'Dashboard package' do
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

    context 'Dashboard sysconfig file' do
      let(:facts) { {:osfamily => 'redhat',
                     :operatingsystemrelease => '6.4',
                     :ports_file => '/etc/httpd/ports.conf"',
                     :concat_basedir => '/tmp' } }
      it {
        should include_class('puppet::dashboard')
        should contain_file('dashboard_sysconfig').with({
          'path'    => '/etc/sysconfig/puppet-dashboard',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
      }
    end

    context 'Dashboard sysconfig file content' do
      let(:facts) { {:osfamily => 'redhat',
                     :operatingsystemrelease => '6.4',
                     :ports_file => '/etc/httpd/ports.conf"',
                     :concat_basedir => '/tmp' } }
      it {
        should include_class('puppet::dashboard')
        should contain_file('dashboard_sysconfig') \
                  .with_content(/^DASHBOARD_PORT=3000$/)
      }
    end

    context 'Dashboard service' do
      let(:facts) { {:osfamily => 'redhat',
                     :operatingsystemrelease => '6.4',
                     :ports_file => '/etc/httpd/ports.conf"',
                     :concat_basedir => '/tmp' } }
      it {
        should include_class('puppet::dashboard')
        should contain_service('puppet-dashboard').with({
          'ensure'    => 'stopped',
          'enable'    => false,
        })
      }
    end

    context 'Dashboard workers service' do
      let(:facts) { {:osfamily => 'redhat',
                     :operatingsystemrelease => '6.4',
                     :ports_file => '/etc/httpd/ports.conf"',
                     :concat_basedir => '/tmp' } }
      it {
        should include_class('puppet::dashboard')
        should contain_service('puppet-dashboard-workers').with({
          'ensure'    => 'stopped',
          'enable'    => false,
        })
      }
    end
  end
end
