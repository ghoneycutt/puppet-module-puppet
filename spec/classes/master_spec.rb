require 'spec_helper'
describe 'puppet::master' do

  describe 'class puppet::master' do

    context 'Puppetmaster auth.conf configuration file' do
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :concat_basedir         => '/tmp',
          :puppet_reportdir       => '/var/lib/puppet/reports',
          :processorcount         => '8',
        }
      end

      it { should contain_class('puppet::master') }

      it { should contain_file('/etc/puppet/auth.conf').with({
          'owner' => 'root',
        })
      }
    end

    context 'Puppetmaster fileserver.conf configuration file' do
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :concat_basedir         => '/tmp',
          :puppet_reportdir       => '/var/lib/puppet/reports',
          :processorcount         => '8',
        }
      end

      it { should contain_class('puppet::master') }

      it { should contain_file('/etc/puppet/fileserver.conf').with({
          'owner' => 'root',
        })
      }
    end

    context 'Puppetmaster sysconfig file on osfamily RedHat' do
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :concat_basedir         => '/tmp',
          :puppet_reportdir       => '/var/lib/puppet/reports',
          :processorcount         => '8',
        }
      end

      it { should contain_class('puppet::master') }

      it { should contain_file('puppetmaster_sysconfig').with_content(/^#PUPPETMASTER_LOG=syslog$/) }
    end

    context 'Puppetmaster sysconfig file on osfamily Debian' do
      let(:facts) do
        { :osfamily               => 'Debian',
          :operatingsystemrelease => '7',
          :concat_basedir         => '/tmp',
          :puppet_reportdir       => '/var/lib/puppet/reports',
          :processorcount         => '8',
        }
      end

      it { should contain_class('puppet::master') }

      it { should contain_file('puppetmaster_sysconfig').with_content(/^START=no$/) }
      it { should contain_file('puppetmaster_sysconfig').with_content(/^DAEMON_OPTS=""$/) }
      it { should contain_file('puppetmaster_sysconfig').with_content(/^PORT=8140$/) }
    end

    context 'Puppetmaster sysconfig file on invalid osfmaily' do
      let(:facts) do
        { :osfamily               => 'invalid',
          :operatingsystemrelease => '6.4',
          :concat_basedir         => '/tmp',
          :puppet_reportdir       => '/var/lib/puppet/reports',
          :processorcount         => '8',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('puppet::master')
        }.to raise_error(Puppet::Error,/puppet::master supports osfamilies Debian and RedHat. Detected osfamily is <invalid>./)
      end
    end

    context 'Puppetmaster sysconfig file specified as invalid path' do
      let(:params) { { :sysconfig_path => 'invalid/path/statement' } }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :concat_basedir         => '/tmp',
          :puppet_reportdir       => '/var/lib/puppet/reports',
          :processorcount         => '8',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('puppet::master')
        }.to raise_error(Puppet::Error)
      end
    end

    context 'Puppetmaster rack directory' do
      let(:params) { {:rack_dir => '/foo/bar' } }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :concat_basedir         => '/tmp',
          :puppet_reportdir       => '/var/lib/puppet/reports',
          :processorcount         => '8',
        }
      end

      it { should contain_class('puppet::master') }

      it { should contain_file('/foo/bar').with({
          'ensure' => 'directory',
        })
      }
    end

    context 'Puppetmaster rack configuration file' do
      let(:params) { {:rack_dir => '/foo/bar' } }
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :concat_basedir         => '/tmp',
          :puppet_reportdir       => '/var/lib/puppet/reports',
          :processorcount         => '8',
        }
      end

      it { should contain_class('puppet::master') }

      it { should contain_file('/foo/bar/config.ru').with({
          'owner'   => 'puppet',
          'group'   => 'root',
          'mode'    => '0644',
        })
      }
    end

    context 'Puppetmaster vhost configuration file on osfamily RedHat' do
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :concat_basedir         => '/tmp',
          :puppet_reportdir       => '/var/lib/puppet/reports',
          :fqdn                   => 'my_fqdn.example.com',
          :processorcount         => '8',
        }
      end

      it { should contain_class('puppet::master') }

      puppetmaster_fixture = File.read(fixtures("25-puppetmaster.conf.default_rhel"))
      it { should contain_file('25-puppetmaster.conf').with_content(puppetmaster_fixture) }
    end

    context 'Puppetmaster vhost configuration file on osfamily Debian' do
      let(:facts) do
        { :osfamily               => 'Debian',
          :operatingsystemrelease => '6.0.8',
          :concat_basedir         => '/tmp',
          :puppet_reportdir       => '/var/lib/puppet/reports',
          :fqdn                   => 'my_fqdn.example.com',
          :processorcount         => '8',
        }
      end

      it { should contain_class('puppet::master') }

      puppetmaster_fixture = File.read(fixtures("25-puppetmaster.conf.default_debian"))
      it { should contain_file('25-puppetmaster.conf').with_content(puppetmaster_fixture) }
    end
  end
end
