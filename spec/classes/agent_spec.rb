require 'spec_helper'
describe 'puppet::agent' do

  describe 'class puppet::agent' do

    context 'Puppet agent configfile' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) { { :env => 'production' } }

      it { should include_class('puppet::agent') }

      it { should contain_file('puppet_config').with({
          'path'    => '/etc/puppet/puppet.conf',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
      }
    end

    context 'Puppet agent sysconfig file on osfamily RedHat' do
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
    end

    context 'Puppet agent sysconfig file on osfamily Debian' do
      let(:facts) { { :osfamily => 'Debian' } }
      let(:params) { { :env => 'production' } }

      it { should include_class('puppet::agent') }

      it { should contain_file('puppet_agent_sysconfig').with({
          'path'    => '/etc/default/puppet',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
      }
    end

    context 'with symlink_puppet_binary enabled with defaults' do
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

    context 'with symlink_puppet_binary enabled with all params specified' do
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

    context 'Puppet agent symlink with invalid puppet_binary' do
      let(:params) { {:env => 'production',
                      :symlink_puppet_binary => 'true',
                      :puppet_binary => 'true',
                      :symlink_puppet_binary_target => '/bar' } }
      it do
        expect { should }.to raise_error(Puppet::Error)
      end
    end

    context 'Puppet agent symlink with invalid symlink_puppet_binary_target' do
      let(:params) { {:env => 'production',
                      :symlink_puppet_binary => 'true',
                      :puppet_binary => '/foo/bar',
                      :symlink_puppet_binary_target => 'undef' } }
      it do
        expect { should }.to raise_error(Puppet::Error)
      end
    end

    context 'Puppet agent sysconfig content' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) { {:env => 'production' } }

      it { should include_class('puppet::agent') }
      it { should contain_file('puppet_agent_sysconfig').with_content(/^#PUPPET_SERVER=puppet$/) }
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

    context 'Puppet agent sysconfig content on osfamily RedHat' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) { { :env => 'production' } }

      it { should include_class('puppet::agent') }

      it { should contain_file('puppet_agent_sysconfig').with_content(/^#PUPPET_SERVER=puppet$/) }
    end

    context 'Puppet agent sysconfig content on osfamily Debian' do
      let(:facts) { { :osfamily => 'Debian' } }
      let(:params) { { :env => 'production' } }

      it { should include_class('puppet::agent') }

      it { should contain_file('puppet_agent_sysconfig').with_content(/^#PUPPET_SERVER=puppet$/) }
    end

    context 'Puppet agent cron' do
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
    end

    context 'Puppet agent cron at boot' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        { :run_method => 'cron',
          :env        => 'production',
        }
      end

      it { should include_class('puppet::agent') }
      it { should contain_cron('puppet_agent_once_at_boot').with({
          'user' => 'root',
          'special' => 'reboot',
        })
      }
    end
  end
end
