require 'spec_helper'
describe 'puppet::agent' do

  describe 'class puppet::agent' do

    context 'Puppet agent configfile' do
      let(:params) { {:env => 'production' } }
      it {
        should include_class('puppet::agent')
        should contain_file('puppet_config').with({
          'path'    => '/etc/puppet/puppet.conf',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
      }
    end

    context 'Puppet agent sysconfig' do
      let(:params) { {:env => 'production' } }
      it {
        should include_class('puppet::agent')
        should contain_file('puppet_agent_sysconfig').with({
          'path'    => '/etc/sysconfig/puppet',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
      }
    end

    context 'Puppet agent symlink' do
      let(:params) { {:env => 'production',
                      :symlink_puppet_binary => 'true',
                      :puppet_binary => '/foo/bar',
                      :symlink_puppet_binary_target => '/bar' } }
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
        expect { should }.to raise_error(Puppet::Error, /#{Regexp.escape('is not an absolute path')}/)
      end
    end
    context 'Puppet agent symlink with invalid symlink_puppet_binary_target' do
      let(:params) { {:env => 'production',
                      :symlink_puppet_binary => 'true',
                      :puppet_binary => '/foo/bar',
                      :symlink_puppet_binary_target => 'undef' } }
      it do
        expect { should }.to raise_error(Puppet::Error, /#{Regexp.escape('is not an absolute path')}/)
      end
    end

    context 'Puppet agent sysconfig content' do
      let(:params) { {:env => 'production' } }
      it {
        should include_class('puppet::agent')
        should contain_file('puppet_agent_sysconfig') \
                          .with_content(/^#PUPPET_SERVER=puppet$/)
      }
    end

    context 'Puppet agent cron' do
      let(:params) { {:run_method => 'cron',
                      :env => 'production' } }
      it {
        should include_class('puppet::agent')
        should contain_cron('puppet_agent').with({
          'user' => 'root',
        })
      }
    end

    context 'Puppet agent cron at boot' do
      let(:params) { {:run_method => 'cron',
                      :env => 'production' } }
      it {
        should include_class('puppet::agent')
        should contain_cron('puppet_agent_once_at_boot').with({
          'user' => 'root',
          'special' => 'reboot',
        })
      }
    end
  end
end
