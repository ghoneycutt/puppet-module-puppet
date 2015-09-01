require 'spec_helper'
describe 'puppet::dashboard::maintenance' do

  describe 'class puppet::dashboard::maintenance' do

    context 'with database dump dir as default value on osfamily RedHat' do
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :concat_basedir         => '/tmp',
          :max_allowed_packet     => 32,
        }
      end

      it { should contain_class('puppet::dashboard::maintenance') }

      it { should contain_file('/var/local').with({
          'ensure' => 'directory',
          'group'  => 'puppet-dashboard',
          'mode'   => '0775',
        })
      }
    end

    context 'with database dump dir as default value on osfamily Debian' do
      let(:facts) do
        { :osfamily               => 'Debian',
          :operatingsystemrelease => '6.0.8',
          :concat_basedir         => '/tmp',
          :max_allowed_packet     => 32,
        }
      end

      it { should contain_class('puppet::dashboard::maintenance') }

      it { should contain_file('/var/local').with({
          'ensure' => 'directory',
          'group'  => 'puppet',
          'mode'   => '0775',
        })
      }
    end

    context 'with database dump dir specified' do
      let(:params) { {:dump_dir => '/foo/bar'} }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :concat_basedir         => '/tmp',
          :max_allowed_packet     => 32,
        }
      end

      it { should contain_class('puppet::dashboard::maintenance') }

      it { should contain_file('/foo/bar').with({
          'ensure' => 'directory',
          'mode'   => '0775',
        })
      }
    end

    context 'with database dump dir specified as invalid value' do
      let(:params) { {:dump_dir => 'invalid/path/statement'} }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :concat_basedir         => '/tmp',
          :max_allowed_packet     => 32,
        }
      end

      it do
        expect {
          should contain_class('puppet::dashboard::maintenance')
        }.to raise_error(Puppet::Error,/"invalid\/path\/statement" is not an absolute path\./)
      end
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

      it { should contain_class('puppet::dashboard::maintenance') }

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

      it { should contain_class('puppet::dashboard::maintenance') }

      it { should contain_cron('purge_old_reports').with({
          'command'  => '/foo/bar',
          'user'     => 'root',
          'hour'     => '0',
          'minute'   => '30',
        })
      }
    end

    context 'Dashboard spool remove reports with remove_old_reports_spool set to invalid string' do
      let(:params) { {:remove_old_reports_spool => 'invalid_string' } }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :concat_basedir         => '/tmp',
          :max_allowed_packet     => 32,
          :operatingsystemrelease => '6.4',
        }
      end

      it do
        expect {
          should contain_class('puppet::dashboard::maintenance')
        }.to raise_error(Puppet::Error,/str2bool\(\): Unknown type of boolean/)
      end
    end

    context 'Dashboard spool remove reports with remove_old_reports_spool set to invalid type - non-boolean and non-string' do
      let(:params) { {:remove_old_reports_spool => ['invalid_type','not_a_string','not_a_boolean'] } }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :concat_basedir         => '/tmp',
          :max_allowed_packet     => 32,
          :operatingsystemrelease => '6.4',
        }
      end

      it do
        expect {
          should contain_class('puppet::dashboard::maintenance')
        }.to raise_error(Puppet::Error,/\["invalid_type", "not_a_string", "not_a_boolean"\] is not a boolean\./)
      end
    end

    [true,'true'].each do |value|
      context "Dashboard spool remove reports with remove_old_reports_spool set to #{value}" do
        let(:params) { {:remove_old_reports_spool => value } }
        let(:facts) do
          { :osfamily               => 'RedHat',
            :concat_basedir         => '/tmp',
            :max_allowed_packet     => 32,
            :operatingsystemrelease => '6.4',
          }
        end

        it { should contain_class('puppet::dashboard::maintenance') }
        it { should contain_cron('remove_old_reports_spool').with({
            'command'  => '/bin/find /usr/share/puppet-dashboard/spool -type f -name "*.yaml" -mtime +7 -exec /bin/rm -f {} \;',
            'ensure'   => 'present',
            'user'     => 'root',
            'hour'     => '0',
            'minute'   => '45',
          })
        }
      end
    end

    context 'Dashboard spool remove reports with params set' do
      let(:params) { {:remove_old_reports_spool => 'true',
                      :remove_reports_spool_user => 'user',
                      :remove_reports_spool_hour => '5',
                      :remove_reports_spool_minute => '6',
                      :reports_spool_dir => '/tmp/foo',
                      :reports_spool_days_to_keep => '10' } }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :concat_basedir         => '/tmp',
          :max_allowed_packet     => 32,
          :operatingsystemrelease => '6.4',
        }
      end

      it { should contain_class('puppet::dashboard::maintenance') }

      it { should contain_cron('remove_old_reports_spool').with({
          'ensure'   => 'present',
          'command'  => '/bin/find /tmp/foo -type f -name "*.yaml" -mtime +10 -exec /bin/rm -f {} \;',
          'user'     => 'user',
          'hour'     => '5',
          'minute'   => '6',
        })
      }
    end

    [false,'false'].each do |value|
      context "Dashboard spool remove reports with remove_old_reports_spool set to #{value}" do
        let(:params) { {:remove_old_reports_spool => value } }
        let(:facts) do
          { :osfamily               => 'RedHat',
            :concat_basedir         => '/tmp',
            :max_allowed_packet     => 32,
            :operatingsystemrelease => '6.4',
          }
        end

        it { should contain_class('puppet::dashboard::maintenance') }

        it { should contain_cron('remove_old_reports_spool').with({
            'ensure'   => 'absent',
          })
        }
      end
    end

    context 'with reports_spool_dir set to an invalid path' do
      let(:params) { {:reports_spool_dir=> 'invalid/path/statement' } }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :concat_basedir         => '/tmp',
          :max_allowed_packet     => 32,
          :operatingsystemrelease => '6.4',
        }
      end

      it do
        expect {
          should contain_class('puppet::dashboard::maintenance')
        }.to raise_error(Puppet::Error,/"invalid\/path\/statement" is not an absolute path\./)
      end
    end

    context 'with dump_database_command set to default value on osfamily RedHat' do
      let(:facts) do
        { :osfamily               => 'RedHat',
          :concat_basedir         => '/tmp',
          :max_allowed_packet     => 32,
          :operatingsystemrelease => '6.4',
        }
      end

      it { should contain_class('puppet::dashboard::maintenance') }

      it { should contain_cron('dump_dashboard_database').with({
          'command'  => 'cd ~puppet-dashboard && sudo -u puppet-dashboard /usr/bin/rake -f /usr/share/puppet-dashboard/Rakefile RAILS_ENV=production FILE=/var/local/dashboard-`date -I`.sql db:raw:dump >> /var/log/puppet/dashboard_maintenance.log 2>&1 && bzip2 -v9 /var/local/dashboard-`date -I`.sql >> /var/log/puppet/dashboard_maintenance.log 2>&1',
          'user'     => 'root',
          'hour'     => '1',
          'minute'   => '0',
        })
      }
    end

    context 'with dump_database_command set to default value on osfamily Debian' do
      let(:facts) do
        { :osfamily               => 'Debian',
          :concat_basedir         => '/tmp',
          :max_allowed_packet     => 32,
          :operatingsystemrelease => '6.0.8',
        }
      end

      it { should contain_class('puppet::dashboard::maintenance') }

      it { should contain_cron('dump_dashboard_database').with({
          'command'  => 'cd ~puppet-dashboard && sudo -u puppet /usr/bin/rake -f /usr/share/puppet-dashboard/Rakefile RAILS_ENV=production FILE=/var/local/dashboard-`date -I`.sql db:raw:dump >> /var/log/puppet/dashboard_maintenance.log 2>&1 && bzip2 -v9 /var/local/dashboard-`date -I`.sql >> /var/log/puppet/dashboard_maintenance.log 2>&1',
          'user'     => 'root',
          'hour'     => '1',
          'minute'   => '0',
        })
      }
    end

    describe 'with dump_database_command specified' do
      let(:facts) do
        { :osfamily               => 'RedHat',
          :concat_basedir         => '/tmp',
          :max_allowed_packet     => 32,
          :operatingsystemrelease => '6.4',
        }
      end

      ['/usr/bin/rake -f /usr/share/puppet-dashboard/Rakefile RAILS_ENV=production reports:prune upto=12 unit=hours','/foo/bar'].each do |value|
        context "to valid #{value} (as #{value.class})" do
          let (:params) {{'dump_database_command' => value }}

          it { should contain_cron('dump_dashboard_database').with({
              'command'  => "#{value}",
              'user'     => 'root',
              'hour'     => '1',
              'minute'   => '0',
            })
          }
        end
      end

      [true,['array'],a = { 'ha' => 'sh' }].each do |value|
        context "to invalid #{value} (as #{value.class})" do
          let (:params) {{'dump_database_command' => value }}

          it 'should fail' do
            expect {
              should contain_class('puppet::dashboard::maintenance')
            }.to raise_error(Puppet::Error,/is not a string.  It looks to be a/)
          end
        end
      end

    end

    describe 'with reports_days_to_keep specified' do
      let(:facts) do
        { :osfamily               => 'RedHat',
          :concat_basedir         => '/tmp',
          :max_allowed_packet     => 32,
          :operatingsystemrelease => '6.4',
        }
      end

      [242,'42'].each do |value|
        context "to valid #{value} (as #{value.class})" do
          let (:params) {{'reports_days_to_keep' => value }}

          it { should contain_cron('purge_old_reports').with({
              'command'  => "/usr/bin/rake -f /usr/share/puppet-dashboard/Rakefile RAILS_ENV=production reports:prune upto=#{value} unit=day >> /var/log/puppet/dashboard_maintenance.log",
              'user'     => 'root',
              'hour'     => '0',
              'minute'   => '30',
            })
          }
        end
      end

      [2.42,true,'string',['array'],a = { 'ha' => 'sh' }].each do |value|
        context "to invalid #{value} (as #{value.class})" do
          let (:params) {{'reports_days_to_keep' => value }}

          it 'should fail' do
            expect {
              should contain_class('puppet::dashboard::maintenance')
            }.to raise_error(Puppet::Error,/validate_integer\(\)/)
          end
        end
      end

    end

    context 'Dashboard database backup cleanup' do
      let(:facts) do
        { :osfamily               => 'RedHat',
          :concat_basedir         => '/tmp',
          :max_allowed_packet     => 32,
          :operatingsystemrelease => '6.4',
        }
      end

      it { should contain_class('puppet::dashboard::maintenance') }

      it { should contain_cron('purge_old_db_backups').with({
          'user'     => 'root',
          'hour'     => '2',
          'minute'   => '0',
        })
      }
    end
  end
end
