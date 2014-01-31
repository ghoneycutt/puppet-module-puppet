require 'spec_helper'
describe 'puppet::dashboard' do

  describe 'class puppet::dashboard' do
    describe 'with dashboard_package set' do
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :ports_file             => '/etc/httpd/ports.conf"',
          :concat_basedir         => '/tmp',
        }
      end
      context 'to a string' do
        let(:params) { {:dashboard_package => 'puppet-dashboard' } }

        it { should contain_class('puppet::dashboard') }

        it { should contain_package('puppet-dashboard').with({
            'ensure' => 'present',
          })
        }
      end

      context 'to an array' do
        let(:params) { {:dashboard_package => ['puppet-dashboard','pdb-somethingelse'] } }

        it { should contain_class('puppet::dashboard') }

        it { should contain_package('puppet-dashboard').with({
            'ensure' => 'present',
          })
        }

        it { should contain_package('pdb-somethingelse').with({
            'ensure' => 'present',
          })
        }
      end

      context 'to an invalid type (boolean)' do
        let(:params) { {:dashboard_package => true } }

        it 'should fail' do
          expect {
            should contain_class('puppet::dashboard')
          }.to raise_error(Puppet::Error,/puppet::dashboard::dashboard_package must be a string or an array./)
        end
      end
    end

    context 'external_node_script on osfamily RedHat with default options' do
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :ports_file             => '/etc/httpd/ports.conf"',
          :concat_basedir         => '/tmp',
        }
      end

      it { should contain_class('puppet::dashboard') }

      it { should contain_file('external_node_script').with({
          'ensure'  => 'file',
          'path'    => '/usr/share/puppet-dashboard/bin/external_node',
          'owner'   => 'puppet-dashboard',
          'group'   => 'puppet-dashboard',
          'mode'    => '0755',
          'require' => 'Package[puppet-dashboard]',
        })
      }
    end

    context 'external_node_script on osfamily Debian with default options' do
      let(:facts) do
        { :osfamily               => 'Debian',
          :operatingsystemrelease => '6.0.8',
          :ports_file             => '/etc/httpd/ports.conf"',
          :concat_basedir         => '/tmp',
        }
      end

      it { should contain_class('puppet::dashboard') }

      it { should contain_file('external_node_script').with({
          'ensure'  => 'file',
          'path'    => '/usr/share/puppet-dashboard/bin/external_node',
          'owner'   => 'puppet',
          'group'   => 'puppet',
          'mode'    => '0755',
          'require' => 'Package[puppet-dashboard]',
        })
      }
    end

    context 'external_node_script with non-default external_node_script specified' do
      let(:params) { { :external_node_script_path => '/opt/local/puppet-dashboard/bin/external_node' } }
      let(:facts) do
        { :osfamily               => 'Debian',
          :operatingsystemrelease => '6.0.8',
          :ports_file             => '/etc/httpd/ports.conf"',
          :concat_basedir         => '/tmp',
        }
      end

      it { should contain_class('puppet::dashboard') }

      it { should contain_file('external_node_script').with({
          'ensure'  => 'file',
          'path'    => '/opt/local/puppet-dashboard/bin/external_node',
          'owner'   => 'puppet',
          'group'   => 'puppet',
          'mode'    => '0755',
          'require' => 'Package[puppet-dashboard]',
        })
      }
    end

    context 'external_node_script with invalid path specified' do
      let(:params) { { :external_node_script_path => 'invalid/path/statement' } }
      let(:facts) do
        { :osfamily               => 'Debian',
          :operatingsystemrelease => '6.0.8',
          :ports_file             => '/etc/httpd/ports.conf"',
          :concat_basedir         => '/tmp',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('puppet::dashboard')
        }.to raise_error(Puppet::Error)
      end
    end

    context 'Dashboard sysconfig file on osfamily RedHat' do
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :ports_file             => '/etc/httpd/ports.conf"',
          :concat_basedir         => '/tmp',
        }
      end

      it { should contain_class('puppet::dashboard') }

      it { should contain_file('dashboard_sysconfig').with({
          'ensure' => 'file',
          'path'   => '/etc/sysconfig/puppet-dashboard',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0644',
        })
      }

      it { should contain_file('dashboard_sysconfig').with_content(/^DASHBOARD_PORT=3000$/) }
    end

    context 'Dashboard sysconfig file on osfamily Debian' do
      let(:facts) do
        { :osfamily               => 'Debian',
          :operatingsystemrelease => '7',
          :ports_file             => '/etc/httpd/ports.conf"',
          :concat_basedir         => '/tmp',
        }
      end

      it { should contain_class('puppet::dashboard') }

      it { should contain_file('dashboard_sysconfig').with({
          'ensure' => 'file',
          'path'   => '/etc/default/puppet-dashboard',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0644',
        })
      }

      it { should_not contain_file('dashboard_sysconfig').with_content(/^START=yes$/) }
      it { should contain_file('dashboard_sysconfig').with_content(/^DASHBOARD_HOME=\/usr\/share\/puppet-dashboard$/) }
      it { should contain_file('dashboard_sysconfig').with_content(/^DASHBOARD_USER=www-data$/) }
      it { should contain_file('dashboard_sysconfig').with_content(/^DASHBOARD_RUBY=\/usr\/bin\/ruby$/) }
      it { should contain_file('dashboard_sysconfig').with_content(/^DASHBOARD_ENVIRONMENT=production$/) }
      it { should contain_file('dashboard_sysconfig').with_content(/^DASHBOARD_IFACE=0.0.0.0$/) }
      it { should contain_file('dashboard_sysconfig').with_content(/^DASHBOARD_PORT=3000$/) }
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
          should contain_class('puppet::dashboard')
        }.to raise_error(Puppet::Error,/puppet::dashboard supports osfamilies Debian and RedHat. Detected osfamily is <invalid>./)
      end
    end

    context 'Dashboard sysconfig specified with invalid path' do
      let(:params) { { :sysconfig_path => 'invalid/path/statement' } }
      let(:facts) do
        { :osfamily               => 'Debian',
          :operatingsystemrelease => '7',
          :ports_file             => '/etc/httpd/ports.conf"',
          :concat_basedir         => '/tmp',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('puppet::dashboard')
        }.to raise_error(Puppet::Error)
      end
    end

    context 'Dashboard service' do
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :ports_file             => '/etc/httpd/ports.conf"',
          :concat_basedir         => '/tmp',
        }
      end

      it { should contain_class('puppet::dashboard') }

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

      it { should contain_class('puppet::dashboard') }

      it { should contain_service('puppet-dashboard-workers').with({
          'ensure'    => 'stopped',
          'enable'    => false,
        })
      }
    end
  end
end
