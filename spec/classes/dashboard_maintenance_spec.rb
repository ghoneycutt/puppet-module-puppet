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

    context 'Dashboard database dump' do
      let(:params) { {:dump_database_command => '/foo/bar' } }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :concat_basedir         => '/tmp',
          :max_allowed_packet     => 32,
          :operatingsystemrelease => '6.4',
        }
      end

      it { should include_class('puppet::dashboard::maintenance') }

      it { should contain_cron('dump_dashboard_database').with({
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
