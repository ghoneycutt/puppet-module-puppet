require 'spec_helper'
describe 'puppet::agent' do

  describe 'config file' do

    context 'default settings' do
      let(:facts) do
        { :osfamily => 'RedHat',
          :fqdn     => 'agent.example.com',
        }
      end
      let(:params) { { :env => 'production' } }

      it { should include_class('puppet::agent') }

      it { should contain_file('puppet_config').with({
          'path'    => '/etc/puppet/puppet.conf',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
      }

      it { should contain_file('puppet_config').with_content(/^    logdir = \/var\/log\/puppet$/) }
      it { should contain_file('puppet_config').with_content(/^    rundir = \/var\/run\/puppet$/) }
      it { should contain_file('puppet_config').with_content(/^    ssldir = \$vardir\/ssl$/) }
      it { should contain_file('puppet_config').with_content(/^    archive_files = true$/) }
      it { should contain_file('puppet_config').with_content(/^    archive_file_server = puppet$/) }
      it { should contain_file('puppet_config').with_content(/^    classfile = \$vardir\/classes.txt$/) }
      it { should contain_file('puppet_config').with_content(/^    localconfig = \$vardir\/localconfig$/) }
      it { should contain_file('puppet_config').with_content(/^    certname = agent.example.com$/) }
      it { should contain_file('puppet_config').with_content(/^    server = puppet$/) }
      it { should_not contain_file('puppet_config').with_content(/ca_server =/) }
      it { should contain_file('puppet_config').with_content(/^    report = true$/) }
      it { should contain_file('puppet_config').with_content(/^    graph = true$/) }
      it { should contain_file('puppet_config').with_content(/^    pluginsync = true$/) }
      it { should contain_file('puppet_config').with_content(/^    noop = false$/) }
      it { should_not contain_file('puppet_config').with_content(/^   environment = production$/) }
    end
  end

  describe 'sysconfig file' do
    context "Puppet agent sysconfig file on osfamily RedHat" do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) { { :env => 'production' } }

      it { should include_class('puppet::agent') }

      it { should contain_file('puppet_agent_sysconfig').with({
          'path'    => '/etc/sysconfig/puppet',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
      }

      it { should contain_file('puppet_agent_sysconfig').with_content(/^#PUPPET_SERVER=puppet$/) }
    end

    context 'Puppet agent sysconfig file on osfamily Debian' do
      let(:facts) do
        { :osfamily  => 'Debian',
          :lsbdistid => 'Debian',
        }
      end
      let(:params) { { :env => 'production' } }

      it { should include_class('puppet::agent') }

      it { should contain_file('puppet_agent_sysconfig').with({
          'path'    => '/etc/default/puppet',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
      }

      it { should contain_file('puppet_agent_sysconfig').with_content(/^#PUPPET_SERVER=puppet$/) }
    end

    context 'Puppet agent sysconfig file on Ubuntu' do
      let(:facts) do
        { :osfamily  => 'Debian',
          :lsbdistid => 'Ubuntu',
        }
      end
      let(:params) { { :env => 'production' } }

      it { should include_class('puppet::agent') }

      it { should contain_file('puppet_agent_sysconfig').with({
          'path'    => '/etc/default/puppet',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
      }

      it { should contain_file('puppet_agent_sysconfig').with_content(/^#PUPPET_SERVER=puppet$/) }
    end

    context 'Puppet agent sysconfig file on osfamily Solaris' do
      let(:facts) { { :osfamily => 'Solaris' } }
      let(:params) { { :env => 'production' } }

      it { should include_class('puppet::agent') }

      it { should_not contain_file('puppet_agent_sysconfig') }
    end

    context 'Puppet agent sysconfig file on invalid osfamily' do
      let(:facts) { { :osfamily => 'invalid' } }
      let(:params) { { :env => 'production' } }

      it 'should fail' do
        expect {
          should include_class('puppet::agent')
        }.to raise_error(Puppet::Error,/puppet::agent supports osfamilies Debian and RedHat. Detected osfamily is <invalid>./)
      end
    end
  end

  describe 'with symlink_puppet_binary' do
    context 'enabled with defaults' do
      let(:facts) { { :osfamily => 'Debian' } }
      let(:params) do
        { :env                          => 'production',
          :symlink_puppet_binary        => 'true',
        }
      end

      it {
        should contain_file('puppet_symlink').with({
          'path'    => '/usr/local/bin/puppet',
          'target'  => '/usr/bin/puppet',
          'ensure'  => 'link',
        })
      }
    end

    context 'enabled with all params specified' do
      let(:facts) { { :osfamily => 'Debian' } }
      let(:params) do
        { :env                          => 'production',
          :symlink_puppet_binary        => 'true',
          :puppet_binary                => '/foo/bar',
          :symlink_puppet_binary_target => '/bar',
        }
      end

      it {
        should contain_file('puppet_symlink').with({
          'path'    => '/bar',
          'target'  => '/foo/bar',
          'ensure'  => 'link',
        })
      }
    end

    context 'and with invalid puppet_binary' do
      let(:params) { {:env => 'production',
                      :symlink_puppet_binary => 'true',
                      :puppet_binary => 'true',
                      :symlink_puppet_binary_target => '/bar' } }
      it do
        expect { should }.to raise_error(Puppet::Error)
      end
    end

    context 'and with invalid symlink_puppet_binary_target' do
      let(:params) { {:env => 'production',
                      :symlink_puppet_binary => 'true',
                      :puppet_binary => '/foo/bar',
                      :symlink_puppet_binary_target => 'undef' } }
      it do
        expect { should }.to raise_error(Puppet::Error)
      end
    end
  end

  describe 'cron' do
    context 'with run_method set to cron' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        { :run_method => 'cron',
          :env        => 'production',
        }
      end

      it { should include_class('puppet::agent') }

      it { should contain_cron('puppet_agent').with({
          'user' => 'root',
        })
      }

      it { should contain_cron('puppet_agent_once_at_boot').with({
          'user' => 'root',
          'special' => 'reboot',
        })
      }
    end
  end
end
