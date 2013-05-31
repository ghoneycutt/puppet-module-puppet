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

    context 'Dashboard vhost configuration file content' do
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
