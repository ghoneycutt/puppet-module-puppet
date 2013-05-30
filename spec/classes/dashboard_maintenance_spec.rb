require 'spec_helper'
describe 'puppet::dashboard::maintenance' do

  describe 'class puppet::dashboard::maintenance' do

    context 'dump dir' do
      let(:params) { {:dump_dir => '/foo/bar'} }
      let(:facts) { {:osfamily => 'redhat', :operatingsystemrelease => '6.4', :concat_basedir => '/tmp', :max_allowed_packet => 32 } }
      it {
        should include_class('puppet::dashboard::maintenance')
        should contain_file('/foo/bar').with({
          'ensure' => 'directory',
        })
      }
    end

    context 'Database maintenance' do
      let(:params) { {:db_optimization_command => '/foo/bar',
                      :purge_old_reports_command => '/foo/bar',
                      :dump_database_command => '/foo/bar' } }
      let(:facts) { {:osfamily => 'redhat',
                     :concat_basedir => '/tmp',
                     :max_allowed_packet => 32,
                     :operatingsystemrelease => '6.4' } }
      it {
        should include_class('puppet::dashboard::maintenance')
        should contain_cron('monthly_dashboard_database_optimization').with({
          'command'  => '/foo/bar',
          'user'     => 'root',
          'hour'     => '0',
          'minute'   => '0',
          'monthday' => '1',
        })
        should contain_cron('purge_old_reports').with({
          'command'  => '/foo/bar',
          'user'     => 'root',
          'hour'     => '0',
          'minute'   => '30',
        })
        should contain_cron('dump_dashboard_database').with({
          'command'  => '/foo/bar',
          'user'     => 'root',
          'hour'     => '1',
          'minute'   => '0',
        })
      }
    end
  end
end
