require 'spec_helper'
describe 'puppet::dashboard' do

  describe 'class puppet::dashboard' do
    describe 'security settings' do
      context 'when htpasswd_path is invalid it should fail' do
        let(:params) { { :htpasswd_path => 'not/a/valid/path' } }
        let(:facts) { {:osfamily => 'redhat',
                       :operatingsystemrelease => '6.4',
                       :ports_file => '/etc/httpd/ports.conf"',
                       :concat_basedir => '/tmp',
                       :domain => 'example.com'
        } }
        it do
          expect {
            should include_class('puppet::dashboard')
          }.to raise_error(Puppet::Error)
        end
      end

      context 'when security is invalid it should fail' do
        let(:params) { { :security => 'invalid' } }
        let(:facts) { {:osfamily => 'redhat',
                       :operatingsystemrelease => '6.4',
                       :ports_file => '/etc/httpd/ports.conf"',
                       :concat_basedir => '/tmp',
                       :domain => 'example.com'
        } }
        it do
          expect {
            should include_class('puppet::dashboard')
          }.to raise_error(Puppet::Error,/Security is <invalid> which does not match regex. Valid values are none and htpasswd./)
        end
      end
    end

    describe 'Dashboard vhost configuration file content' do
      context 'with default settings' do
        let(:facts) { {:osfamily => 'redhat',
                       :operatingsystemrelease => '6.4',
                       :ports_file => '/etc/httpd/ports.conf"',
                       :concat_basedir => '/tmp',
                       :domain => 'example.com' } }
        it {
          should include_class('puppet::dashboard')
          should contain_file('dashboard_vhost') \
                    .with_content(/^\s*ServerName puppet.example.com$/)
        }
      end

      context 'with security set to none' do
        let(:params) { { :security => 'none' } }
        let(:facts) { {:osfamily               => 'redhat',
                       :operatingsystemrelease => '6.4',
                       :ports_file             => '/etc/httpd/ports.conf"',
                       :concat_basedir         => '/tmp',
        } }
        it {
          should include_class('puppet::dashboard')
          should_not contain_file('dashboard_vhost').with_content(/(\s+|)AuthType(\s+)basic(\s*)/)
        }
      end

      context 'with security set to htpasswd' do
        let(:params) { { :security => 'htpasswd' } }
        let(:facts) { {:osfamily               => 'redhat',
                       :operatingsystemrelease => '6.4',
                       :ports_file             => '/etc/httpd/ports.conf"',
                       :concat_basedir         => '/tmp',
        } }
        it {
          should include_class('puppet::dashboard')
          should contain_file('dashboard_vhost').with_content(/(\s+|)AuthType(\s+)basic(\s*)/)
        }
      end
    end

    describe 'need to refactor contexts' do

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

    context 'Dashboard database configuration file' do
      let(:facts) { {:osfamily => 'redhat',
                     :operatingsystemrelease => '6.4',
                     :ports_file => '/etc/httpd/ports.conf"',
                     :concat_basedir => '/tmp' } }
      it {
        should include_class('puppet::dashboard')
        should contain_file('database_config').with({
          'path'    => '/usr/share/puppet-dashboard/config/database.yml',
          'owner'   => 'puppet-dashboard',
          'group'   => 'puppet-dashboard',
          'mode'    => '0640',
        })
      }
    end

    context 'Dashboard database configuration file content' do
      let(:facts) { {:osfamily => 'redhat',
                     :operatingsystemrelease => '6.4',
                     :ports_file => '/etc/httpd/ports.conf"',
                     :concat_basedir => '/tmp' } }
      it {
        should include_class('puppet::dashboard')
        should contain_file('database_config') \
                  .with_content(/^\s*username: dashboard$/)
      }
    end

    context 'Dashboard vhost configuration file' do
      let(:facts) { {:osfamily => 'redhat',
                     :operatingsystemrelease => '6.4',
                     :ports_file => '/etc/httpd/ports.conf"',
                     :concat_basedir => '/tmp',
                     :domain => 'example.com' } }
      it {
        should include_class('puppet::dashboard')
        should contain_file('dashboard_vhost').with({
          'path'    => '/etc/httpd/conf.d/dashboard.conf',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
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

    context 'Dashboard Mysql Database' do
      let(:facts) { {:osfamily => 'redhat',
                     :operatingsystemrelease => '6.4',
                     :ports_file => '/etc/httpd/ports.conf"',
                     :concat_basedir => '/tmp' } }
      it {
        should include_class('puppet::dashboard')
        should contain_mysql__db('dashboard').with({
          'user'     => 'dashboard',
          'password' => 'puppet',
          'host'     => 'localhost',
        })
      }
    end

    context 'Dashboard database migration' do
      let(:facts) { {:osfamily => 'redhat',
                     :operatingsystemrelease => '6.4',
                     :ports_file => '/etc/httpd/ports.conf"',
                     :concat_basedir => '/tmp' } }
      it {
        should include_class('puppet::dashboard')
        should contain_exec('migrate_dashboard_database').with({
          'command'     => 'rake RAILS_ENV=production db:migrate',
          'path'        => '/bin:/usr/bin:/sbin:/usr/sbin',
          'cwd'         => '/usr/share/puppet-dashboard',
          'refreshonly' => true,
        })
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
          'ensure'    => 'running',
          'enable'    => true,
        })
      }
    end
    end
  end
end
