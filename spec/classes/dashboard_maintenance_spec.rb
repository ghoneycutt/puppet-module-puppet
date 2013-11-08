require 'spec_helper'
describe 'puppet::dashboard::maintenance' do

  describe 'class puppet::dashboard::maintenance' do

    context 'Dashboard database dump dir' do
      let(:params) { {:dump_dir => '/foo/bar'} }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :concat_basedir         => '/tmp',
          :max_allowed_packet     => 32,
        }
      end

      it { should include_class('puppet::dashboard::maintenance') }

      it { should contain_file('/foo/bar').with({
          'ensure' => 'directory',
        })
      }
    end

    context 'Dashboard database optimization' do
      let(:params) { {:db_optimization_command => '/foo/bar' } }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :concat_basedir         => '/tmp',
          :max_allowed_packet     => 32,
          :operatingsystemrelease => '6.4',
        }
      end

      it { should include_class('puppet::dashboard::maintenance') }

      it { should contain_cron('monthly_dashboard_database_optimization').with({
          'command'  => '/foo/bar',
          'user'     => 'root',
          'hour'     => '0',
          'minute'   => '0',
          'monthday' => '1',
        })
      }
    end

    context 'Dashboard database purge reports' do
      let(:params) { {:purge_old_reports_command => '/foo/bar' }}
      let(:facts) do
        { :osfamily               => 'RedHat',
          :concat_basedir         => '/tmp',
          :max_allowed_packet     => 32,
          :operatingsystemrelease => '6.4',
        }
      end

      it { should include_class('puppet::dashboard::maintenance') }

      it { should contain_cron('purge_old_reports').with({
          'command'  => '/foo/bar',
          'user'     => 'root',
          'hour'     => '0',
          'minute'   => '30',
        })
      }
    end

    context 'Dashboard spool remove reports with default params' do
      let(:params) { {:remove_old_reports_spool => 'true' }}
      let(:facts) { {:osfamily => 'RedHat',
                     :concat_basedir => '/tmp',
                     :max_allowed_packet => 32,
                     :operatingsystemrelease => '6.4' } }
      it {
        should include_class('puppet::dashboard::maintenance')
        should contain_cron('remove_old_reports_spool').with({
          'command'  => '/bin/find /usr/share/puppet-dashboard/spool -type f -name "*.yaml" -mtime +7 -exec /bin/rm -f {} \;',
          'ensure'   => 'present',
          'user'     => 'root',
          'hour'     => '0',
          'minute'   => '45',
        })
      }
    end

    context 'Dashboard spool remove reports with params set' do
      let(:params) { {:remove_old_reports_spool => 'true',
                      :remove_reports_spool_user => 'user',
                      :remove_reports_spool_hour => '5',
                      :remove_reports_spool_minute => '6',
                      :reports_spool_dir => '/tmp/foo',
                      :reports_spool_days_to_keep => '10' } }
      let(:facts) { {:osfamily => 'RedHat',
                     :concat_basedir => '/tmp',
                     :max_allowed_packet => 32,
                     :operatingsystemrelease => '6.4' } }
      it {
        should include_class('puppet::dashboard::maintenance')
        should contain_cron('remove_old_reports_spool').with({
          'ensure'   => 'present',
          'command'  => '/bin/find /tmp/foo -type f -name "*.yaml" -mtime +10 -exec /bin/rm -f {} \;',
          'user'     => 'user',
          'hour'     => '5',
          'minute'   => '6',
        })
      }
    end

    context 'Dashboard spool remove reports with remove_old_reports_spool set to false' do
      let(:params) { {:remove_old_reports_spool => 'false' }}
      let(:facts) { {:osfamily => 'RedHat',
                     :concat_basedir => '/tmp',
                     :max_allowed_packet => 32,
                     :operatingsystemrelease => '6.4' } }
      it {
        should include_class('puppet::dashboard::maintenance')
        should contain_cron('remove_old_reports_spool').with({
          'ensure'   => 'absent',
        })
      }
    end

    context 'with reports_spool_dir set to an invalid path' do
      let(:params) { {:reports_spool_dir=> 'invalid/path/param' }}
      let(:facts) do
        { :osfamily => 'RedHat',
          :concat_basedir => '/tmp',
          :max_allowed_packet => 32,
          :operatingsystemrelease => '6.4',
        }
      end

      it do
        expect {
          should include_class('puppet::dashboard::maintenance')
        }.to raise_error(Puppet::Error)
      end
    end

    context 'Dashboard database dump' do
      let(:params) { {:dump_database_command => '/foo/bar' } }
      let(:facts) { {:osfamily => 'RedHat',
                     :concat_basedir => '/tmp',
                     :max_allowed_packet => 32,
                     :operatingsystemrelease => '6.4' } }
      it {
        should include_class('puppet::dashboard::maintenance')
        should contain_cron('dump_dashboard_database').with({
          'command'  => '/foo/bar',
          'user'     => 'root',
          'hour'     => '1',
          'minute'   => '0',
        })
      }
    end

    context 'Dashboard database backup cleanup' do
      let(:facts) do
        { :osfamily               => 'RedHat',
          :concat_basedir         => '/tmp',
          :max_allowed_packet     => 32,
          :operatingsystemrelease => '6.4',
        }
      end

      it { should include_class('puppet::dashboard::maintenance') }

      it { should contain_cron('purge_old_db_backups').with({
          'user'     => 'root',
          'hour'     => '2',
          'minute'   => '0',
        })
      }
    end
  end
end
