require 'spec_helper'
describe 'puppet::dashboard' do

  describe 'class puppet::dashboard' do
    context 'Dashboard package' do
      let(:params) { {:dashboard_package => 'puppet-dashboard' } }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :ports_file             => '/etc/httpd/ports.conf"',
          :concat_basedir         => '/tmp',
        }
      end

      it { should include_class('puppet::dashboard') }

      it { should contain_package('puppet_dashboard').with({
          'ensure' => 'present',
          'name'   => 'puppet-dashboard',
        })
      }
    end

    context 'Dashboard sysconfig file on osfamily RedHat' do
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :ports_file             => '/etc/httpd/ports.conf"',
          :concat_basedir         => '/tmp',
        }
      end

      it { should include_class('puppet::dashboard') }

      it { should contain_file('dashboard_sysconfig').with({
          'path'    => '/etc/sysconfig/puppet-dashboard',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
      }
    end

    context 'Dashboard sysconfig file on osfamily Debian' do
      let(:facts) do
        { :osfamily               => 'Debian',
          :operatingsystemrelease => '7',
          :ports_file             => '/etc/httpd/ports.conf"',
          :concat_basedir         => '/tmp',
        }
      end

      it { should include_class('puppet::dashboard') }

      it { should contain_file('dashboard_sysconfig').with({
          'path'    => '/etc/default/puppet-dashboard',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
      }
    end

    context 'Dashboard sysconfig file on invalid osfamily' do
      let(:facts) do
        { :osfamily               => 'invalid',
          :operatingsystemrelease => '7',
          :ports_file             => '/etc/httpd/ports.conf"',
          :concat_basedir         => '/tmp',
        }
      end

      it 'should fail' do
        expect {
          should include_class('puppet::dashboard')
        }.to raise_error(Puppet::Error,/puppet::dashboard supports osfamilies Debian and RedHat. Detected osfamily is <invalid>./)
      end
    end

    context 'Dashboard sysconfig file content on osfamily RedHat' do
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :ports_file             => '/etc/httpd/ports.conf"',
          :concat_basedir         => '/tmp',
        }
      end

      it { should include_class('puppet::dashboard') }

      it { should contain_file('dashboard_sysconfig').with_content(/^DASHBOARD_PORT=3000$/) }
    end

    context 'Dashboard sysconfig file content on osfamily Debian' do
      let(:facts) do
        { :osfamily               => 'Debian',
          :operatingsystemrelease => '7',
          :ports_file             => '/etc/httpd/ports.conf"',
          :concat_basedir         => '/tmp',
        }
      end

      it { should include_class('puppet::dashboard') }

      it { should contain_file('dashboard_sysconfig').with_content(/^DASHBOARD_PORT=3000$/) }
    end

    context 'Dashboard service' do
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :ports_file             => '/etc/httpd/ports.conf"',
          :concat_basedir         => '/tmp',
        }
      end

      it { should include_class('puppet::dashboard') }

      it { should contain_service('puppet-dashboard').with({
          'ensure'    => 'stopped',
          'enable'    => false,
        })
      }
    end

    context 'Dashboard workers service' do
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :ports_file             => '/etc/httpd/ports.conf"',
          :concat_basedir         => '/tmp',
        }
      end

      it { should include_class('puppet::dashboard') }

      it { should contain_service('puppet-dashboard-workers').with({
          'ensure'    => 'stopped',
          'enable'    => false,
        })
      }
    end
  end
end
