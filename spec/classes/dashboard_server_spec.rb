require 'spec_helper'

describe 'puppet::dashboard::server' do

  context 'with default dashboard_workers on osfamily RedHat' do
    let(:facts) do
      { :osfamily               => 'RedHat',
        :operatingsystemrelease => '6.4',
        :ports_file             => '/etc/httpd/ports.conf"',
        :processorcount         => '8',
        :concat_basedir         => '/tmp',
      }
    end

    it { should contain_class('puppet::dashboard::server') }

    it { should_not contain_file('dashboard_workers_default') }
  end

  context 'with default dashboard_workers on osfamily Debian' do
    let(:facts) do
      { :osfamily               => 'Debian',
        :operatingsystemrelease => '6.0.8',
        :ports_file             => '/etc/httpd/ports.conf"',
        :processorcount         => '8',
        :concat_basedir         => '/tmp',
      }
    end

    it { should contain_class('puppet::dashboard::server') }

    it { should contain_file('dashboard_workers_default').with({
        'ensure' => 'file',
        'path'   => '/etc/default/puppet-dashboard-workers',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644',
      })
    }

    it { should contain_file('dashboard_workers_default').with_content(/^START=yes$/) }
    it { should contain_file('dashboard_workers_default').with_content(/^NUM_DELAYED_JOB_WORKERS=8$/) }
  end

  context 'with default dashboard_workers set to non-digit' do
    let(:params) { { :dashboard_workers => '8invalid' } }
    let(:facts) do
      { :osfamily               => 'Debian',
        :operatingsystemrelease => '6.0.8',
        :ports_file             => '/etc/httpd/ports.conf"',
        :concat_basedir         => '/tmp',
      }
    end

    it do
      expect {
        should contain_class('puppet::dashboard')
      }.to raise_error(Puppet::Error,/puppet::dashboard::server::dashboard_workers must be a digit. Detected value is <8invalid>./)
    end

  end

  context 'with default htpasswd path on osfamily RedHat' do
    let(:params) do
      { :security => 'htpasswd',
        :htpasswd => {
          'gh' => {
            'cryptpasswd' => 'password',
          },
        }
      }
    end

    let(:facts) do
      { :osfamily               => 'RedHat',
        :operatingsystemrelease => '6.4',
        :ports_file             => '/etc/httpd/ports.conf"',
        :processorcount         => '8',
        :concat_basedir         => '/tmp',
      }
    end

    it { should contain_class('puppet::dashboard::server') }

    it { should contain_file('dashboard_htpasswd_path').with({
        'ensure' => 'file',
        'path'   => '/etc/puppet/dashboard.htpasswd',
        'owner'  => 'root',
        'group'  => 'apache',
        'mode'   => '0640',
      })
    }
  end

  context 'with default htpasswd path on osfamily Debian' do
    let(:params) do
      { :security => 'htpasswd',
        :htpasswd => {
          'gh' => {
            'cryptpasswd' => 'password',
          },
        }
      }
    end
    let(:facts) do
      { :osfamily               => 'Debian',
        :operatingsystemrelease => '6.0.8',
        :ports_file             => '/etc/httpd/ports.conf"',
        :processorcount         => '8',
        :concat_basedir         => '/tmp',
      }
    end

    it { should contain_class('puppet::dashboard::server') }

    it { should contain_file('dashboard_htpasswd_path').with({
        'ensure' => 'file',
        'path'   => '/etc/puppet/dashboard.htpasswd',
        'owner'  => 'root',
        'group'  => 'www-data',
        'mode'   => '0640',
      })
    }
  end

  context 'with htpasswd_path set by user' do
    let(:params) do
      { :htpasswd_path => '/var/www/html/dashboard_passwd',
        :security      => 'htpasswd',
        :htpasswd => {
          'gh' => {
            'cryptpasswd' => 'password',
          },
        }
      }
    end
    let(:facts) do
      { :osfamily               => 'Debian',
        :operatingsystemrelease => '6.0.8',
        :ports_file             => '/etc/httpd/ports.conf"',
        :processorcount         => '8',
        :concat_basedir         => '/tmp',
      }
    end

    it { should contain_class('puppet::dashboard::server') }

    it { should contain_file('dashboard_htpasswd_path').with({
        'ensure' => 'file',
        'path'   => '/var/www/html/dashboard_passwd',
        'owner'  => 'root',
        'group'  => 'www-data',
        'mode'   => '0640',
      })
    }
  end

  context 'with invalid value for htpasswd_path' do
    let(:params) do
      { :htpasswd_path => 'not/a/valid/path',
        :security      => 'htpasswd',
        :htpasswd => {
          'gh' => {
            'cryptpasswd' => 'password',
          },
        }
      }
    end
    let(:facts) do
      { :osfamily               => 'RedHat',
        :operatingsystemrelease => '6.4',
        :ports_file             => '/etc/httpd/ports.conf"',
        :processorcount         => '8',
        :concat_basedir         => '/tmp',
        :domain                 => 'example.com',
      }
    end

    it do
      expect {
        should contain_class('puppet::dashboard')
      }.to raise_error(Puppet::Error,/"not\/a\/valid\/path" is not an absolute path\./)
    end
  end

  [false,'false'].each do |value|
    context "with manage_mysql_options set to <#{value}>" do
      let(:params) { { :manage_mysql_options => "#{value}" } }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :processorcount         => '8',
        }
      end

      it { should contain_class('puppet::dashboard::server') }

      it { should contain_class('mysql::server').with({'override_options' => {},}) }

      it { should contain_file('mysql-config-file').without_content(/max_allowed_packet = 32M/) }

      end
    end

  [true,'true'].each do |value|
    context "with manage_mysql_options set to <#{value}>" do
      let(:params) { { :manage_mysql_options => "#{value}" } }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :processorcount         => '8',
        }
      end

      it { should contain_class('puppet::dashboard::server') }

      it { should contain_file('mysql-config-file').with_content(/^max_allowed_packet = 32M$/) }

      it {
        should contain_class('mysql::server').with({
          'override_options' => {
            'mysqld' => {
              'max_allowed_packet' => '32M',
            },
          },
        })
      }

      end
    end

  ['invalid',[ 'dont', 'like', 'arrays', ], { 'nor' => 'hashes', },  ].each do |value|
    context "with manage_mysql_options set to invalid value <#{value}>" do
      let(:params) { { :manage_mysql_options => "#{value}" } }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :processorcount         => '8',
        }
      end

      it do
        expect {
          should contain_class('puppet::dashboard')
        }.to raise_error(Puppet::Error,/str2bool\(\): Unknown type of boolean/)
      end
    end
  end

  describe 'Dashboard vhost configuration file content' do
    context 'when vhost_path is invalid it should fail' do
      let(:params) { { :vhost_path => 'not/a/valid/path' } }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :ports_file             => '/etc/httpd/ports.conf"',
          :processorcount         => '8',
          :concat_basedir         => '/tmp',
          :domain                 => 'example.com',
        }
      end

      it do
        expect {
          should contain_class('puppet::dashboard')
        }.to raise_error(Puppet::Error,/"not\/a\/valid\/path" is not an absolute path\./)
      end
    end

    context 'when htpasswd_path is invalid it should fail' do
      let(:params) { { :htpasswd_path => 'not/a/valid/path' } }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :ports_file             => '/etc/httpd/ports.conf"',
          :processorcount         => '8',
          :concat_basedir         => '/tmp',
          :domain                 => 'example.com',
        }
      end

      it do
        expect {
          should contain_class('puppet::dashboard')
        }.to raise_error(Puppet::Error,/"not\/a\/valid\/path" is not an absolute path\./)
      end
    end

    context 'when security is invalid it should fail' do
      let(:params) { { :security => 'invalid' } }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :ports_file             => '/etc/httpd/ports.conf"',
          :processorcount         => '8',
          :concat_basedir         => '/tmp',
          :domain                 => 'example.com',
        }
      end

      it do
        expect {
          should contain_class('puppet::dashboard')
        }.to raise_error(Puppet::Error,/Security is <invalid> which does not match regex. Valid values are none and htpasswd./)
      end
    end

    context 'with default settings' do
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :ports_file             => '/etc/httpd/ports.conf"',
          :processorcount         => '8',
          :concat_basedir         => '/tmp',
          :domain                 => 'example.com',
        }
      end

      it { should contain_class('puppet::dashboard::server') }

      it { should contain_file('dashboard_vhost').with_content(/^\s*ServerName puppet.example.com$/) }
    end

    context 'with security set to none' do
      let(:params) { { :security => 'none' } }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :ports_file             => '/etc/httpd/ports.conf"',
          :processorcount         => '8',
          :concat_basedir         => '/tmp',
        }
      end

      it { should contain_class('puppet::dashboard::server') }

      it { should contain_file('dashboard_vhost') }

      it { should_not contain_file('dashboard_vhost').with_content(/(\s+|)AuthType(\s+)basic(\s*)/) }
    end

    context 'with security set to htpasswd' do
      let(:params) { { :security => 'htpasswd' } }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :ports_file             => '/etc/httpd/ports.conf"',
          :processorcount         => '8',
          :concat_basedir         => '/tmp',
        }
      end

      it { should contain_class('puppet::dashboard::server') }

      it { should contain_file('dashboard_vhost').with_content(/(\s+|)AuthType(\s+)basic(\s*)/) }
    end
  end

  context 'with database configuration file on osfamily RedHat' do
    let(:facts) do
      { :osfamily               => 'RedHat',
        :operatingsystemrelease => '6.4',
        :ports_file             => '/etc/httpd/ports.conf"',
        :processorcount         => '8',
        :concat_basedir         => '/tmp',
      }
    end

    it { should contain_class('puppet::dashboard::server') }

    it { should contain_file('database_config').with({
        'path'    => '/usr/share/puppet-dashboard/config/database.yml',
        'owner'   => 'puppet-dashboard',
        'group'   => 'puppet-dashboard',
        'mode'    => '0640',
        'require' => 'Package[puppet-dashboard]',
      })
    }
  end

  context 'with database configuration file on osfamily Debian' do
    let(:facts) do
      { :osfamily               => 'Debian',
        :operatingsystemrelease => '6.0.8',
        :ports_file             => '/etc/httpd/ports.conf"',
        :processorcount         => '8',
        :concat_basedir         => '/tmp',
      }
    end

    it { should contain_class('puppet::dashboard::server') }

    it { should contain_file('database_config').with({
        'path'    => '/usr/share/puppet-dashboard/config/database.yml',
        'owner'   => 'puppet',
        'group'   => 'www-data',
        'mode'    => '0640',
        'require' => 'Package[puppet-dashboard]',
      })
    }
  end

  context 'Dashboard database configuration file content' do
    let(:facts) do
      { :osfamily               => 'RedHat',
        :operatingsystemrelease => '6.4',
        :ports_file             => '/etc/httpd/ports.conf"',
        :processorcount         => '8',
        :concat_basedir         => '/tmp',
      }
    end

    it { should contain_class('puppet::dashboard::server') }

    it { should contain_file('database_config').with_content(/^\s*username: dashboard$/) }
  end

  context 'Dashboard vhost configuration file on osfamily RedHat' do
    let(:facts) do
      { :osfamily               => 'RedHat',
        :operatingsystemrelease => '6.4',
        :ports_file             => '/etc/httpd/ports.conf"',
        :processorcount         => '8',
        :concat_basedir         => '/tmp',
        :domain                 => 'example.com',
      }
    end

    it { should contain_class('puppet::dashboard::server') }

    it { should contain_file('dashboard_vhost').with({
        'ensure'  => 'file',
        'path'    => '/etc/httpd/conf.d/dashboard.conf',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
      })
    }
  end

  context 'Dashboard vhost configuration file on osfamily Debian' do
    let(:facts) do
      { :osfamily               => 'Debian',
        :operatingsystemrelease => '6.0.8',
        :ports_file             => '/etc/httpd/ports.conf"',
        :processorcount         => '8',
        :concat_basedir         => '/tmp',
        :domain                 => 'example.com',
      }
    end

    it { should contain_class('puppet::dashboard::server') }

    it { should contain_file('dashboard_vhost').with({
        'ensure'  => 'file',
        'path'    => '/etc/apache2/sites-enabled/puppetdashboard',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
      })
    }
  end

  context 'Dashboard Mysql Database' do
    let(:facts) do
      { :osfamily               => 'RedHat',
        :operatingsystemrelease => '6.4',
        :ports_file             => '/etc/httpd/ports.conf"',
        :processorcount         => '8',
        :concat_basedir         => '/tmp',
      }
    end

    it { should contain_class('puppet::dashboard::server') }

    it { should contain_mysql__db('dashboard').with({
        'user'     => 'dashboard',
        'password' => 'puppet',
        'host'     => 'localhost',
      })
    }
  end

  context 'Dashboard database migration' do
    let(:facts) do
      { :osfamily => 'RedHat',
        :operatingsystemrelease => '6.4',
        :ports_file             => '/etc/httpd/ports.conf"',
        :processorcount         => '8',
        :concat_basedir         => '/tmp',
      }
    end

    it { should contain_class('puppet::dashboard::server') }

    it { should contain_exec('migrate_dashboard_database').with({
        'command'     => 'rake RAILS_ENV=production db:migrate',
        'path'        => '/bin:/usr/bin:/sbin:/usr/sbin',
        'cwd'         => '/usr/share/puppet-dashboard',
        'refreshonly' => true,
      })
    }
  end

  context 'Dashboard workers service' do
    let(:facts) do
      { :osfamily => 'RedHat',
        :operatingsystemrelease => '6.4',
        :ports_file             => '/etc/httpd/ports.conf"',
        :processorcount         => '8',
        :concat_basedir         => '/tmp',
      }
    end

    it { should contain_class('puppet::dashboard::server') }

    it { should contain_service('puppet-dashboard-workers').with({
        'ensure'    => 'running',
        'enable'    => true,
      })
    }
  end
end
