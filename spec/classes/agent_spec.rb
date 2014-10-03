require 'spec_helper'
describe 'puppet::agent' do

  describe 'config file' do

    context 'with default settings' do
      let(:facts) do
        { :osfamily => 'RedHat',
          :fqdn     => 'agent.example.com',
        }
      end
      let(:params) { { :env => 'production' } }

      it { should contain_class('puppet::agent') }

      it { should contain_file('puppet_config').with({
          'path'    => '/etc/puppet/puppet.conf',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
      }

      it { should contain_file('puppet_config').with_content(/^\ *logdir = \/var\/log\/puppet$/) }
      it { should contain_file('puppet_config').with_content(/^\ *rundir = \/var\/run\/puppet$/) }
      it { should contain_file('puppet_config').with_content(/^\ *ssldir = \$vardir\/ssl$/) }
      it { should contain_file('puppet_config').with_content(/^\ *archive_files = true$/) }
      it { should contain_file('puppet_config').with_content(/^\ *archive_file_server = puppet$/) }
      it { should contain_file('puppet_config').with_content(/^\ *classfile = \$vardir\/classes.txt$/) }
      it { should contain_file('puppet_config').with_content(/^\ *localconfig = \$vardir\/localconfig$/) }
      it { should contain_file('puppet_config').with_content(/^\ *certname = agent.example.com$/) }
      it { should contain_file('puppet_config').with_content(/^\ *server = puppet$/) }
      it { should_not contain_file('puppet_config').with_content(/masterport =/) }
      it { should_not contain_file('puppet_config').with_content(/ca_server =/) }
      it { should_not contain_file('puppet_config').with_content(/^\s*http_proxy_host =/) }
      it { should_not contain_file('puppet_config').with_content(/^\s*http_proxy_port =/) }
      it { should contain_file('puppet_config').with_content(/^\ *report = true$/) }
      it { should contain_file('puppet_config').with_content(/^\ *graph = true$/) }
      it { should contain_file('puppet_config').with_content(/^\ *pluginsync = true$/) }
      it { should contain_file('puppet_config').with_content(/^\ *noop = false$/) }
      it { should_not contain_file('puppet_config').with_content(/environment = production/) }
      it { should contain_file('puppet_config').with_content(/^\s*stringify_facts = true$/) }
      it { should_not contain_file('puppet_config').with_content(/^\s*prerun_command=\/etc\/puppet\/etckeeper-commit-pre$/) }
      it { should_not contain_file('puppet_config').with_content(/^\s*postrun_command=\/etc\/puppet\/etckeeper-commit-post$/) }
    end

    ['false',false].each do |value|
      context "with is_puppet_master set to #{value} (default)" do
        let(:facts) do
          { :osfamily => 'RedHat',
            :fqdn     => 'agent.example.com',
          }
        end
        let(:params) do
          { :env              => 'production',
            :is_puppet_master => value,
          }
        end

        it { should contain_class('puppet::agent') }

        it { should contain_file('puppet_config').with({
            'path'    => '/etc/puppet/puppet.conf',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          })
        }

        it { should contain_file('puppet_config').with_content(/^\ *logdir = \/var\/log\/puppet$/) }
        it { should contain_file('puppet_config').with_content(/^\ *rundir = \/var\/run\/puppet$/) }
        it { should contain_file('puppet_config').with_content(/^\ *ssldir = \$vardir\/ssl$/) }
        it { should contain_file('puppet_config').with_content(/^\ *archive_files = true$/) }
        it { should contain_file('puppet_config').with_content(/^\ *archive_file_server = puppet$/) }
        it { should contain_file('puppet_config').with_content(/^\ *classfile = \$vardir\/classes.txt$/) }
        it { should contain_file('puppet_config').with_content(/^\ *localconfig = \$vardir\/localconfig$/) }
        it { should contain_file('puppet_config').with_content(/^\ *certname = agent.example.com$/) }
        it { should contain_file('puppet_config').with_content(/^\ *server = puppet$/) }
        it { should_not contain_file('puppet_config').with_content(/ca_server =/) }
        it { should contain_file('puppet_config').with_content(/^\ *report = true$/) }
        it { should contain_file('puppet_config').with_content(/^\ *graph = true$/) }
        it { should contain_file('puppet_config').with_content(/^\ *pluginsync = true$/) }
        it { should contain_file('puppet_config').with_content(/^\ *noop = false$/) }
        it { should_not contain_file('puppet_config').with_content(/environment = production/) }
        it { should contain_file('puppet_config').with_content(/^\s*stringify_facts = true$/) }
      end
    end

    ['true',true].each do |value|
      context "with is_puppet_master set to #{value}" do
        let(:facts) do
          { :osfamily => 'RedHat',
            :fqdn     => 'agent.example.com',
          }
        end
        let(:params) do
          { :env              => 'production',
            :is_puppet_master => value,
          }
        end

        it { should contain_class('puppet::agent') }

        it { should contain_file('puppet_config').with({
            'path'    => '/etc/puppet/puppet.conf',
            'content' => nil,
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          })
        }
        it { should_not contain_file('puppet_config').with_content(/^\ *logdir = \/var\/log\/puppet$/) }
        it { should_not contain_file('puppet_config').with_content(/^\ *rundir = \/var\/run\/puppet$/) }
        it { should_not contain_file('puppet_config').with_content(/^\ *ssldir = \$vardir\/ssl$/) }
        it { should_not contain_file('puppet_config').with_content(/^\ *archive_files = true$/) }
        it { should_not contain_file('puppet_config').with_content(/^\ *archive_file_server = puppet$/) }
        it { should_not contain_file('puppet_config').with_content(/^\ *classfile = \$vardir\/classes.txt$/) }
        it { should_not contain_file('puppet_config').with_content(/^\ *localconfig = \$vardir\/localconfig$/) }
        it { should_not contain_file('puppet_config').with_content(/^\ *certname = agent.example.com$/) }
        it { should_not contain_file('puppet_config').with_content(/^\ *server = puppet$/) }
        it { should_not contain_file('puppet_config').with_content(/ca_server =/) }
        it { should_not contain_file('puppet_config').with_content(/^\ *report = true$/) }
        it { should_not contain_file('puppet_config').with_content(/^\ *graph = true$/) }
        it { should_not contain_file('puppet_config').with_content(/^\ *pluginsync = true$/) }
        it { should_not contain_file('puppet_config').with_content(/^\ *noop = false$/) }
        it { should_not contain_file('puppet_config').with_content(/environment = production/) }
        it { should_not contain_file('puppet_config').with_content(/^\s*stringify_facts = true$/) }
      end
    end
  end

  describe 'with stringify_facts' do
    ['true',true].each do |value|
      context "set to #{value}" do
        let(:params) do
          {
            :stringify_facts => value,
            :env             => 'production',
          }
        end
        let(:facts) { { :osfamily => 'RedHat' } }

        it { should contain_file('puppet_config').with_content(/^\s*stringify_facts = true$/) }
      end
    end

    ['false',false].each do |value|
      context "set to #{value}" do
        let(:params) do
          {
            :stringify_facts => value,
            :env             => 'production',
          }
        end
        let(:facts) { { :osfamily => 'RedHat' } }

        it { should contain_file('puppet_config').with_content(/^\s*stringify_facts = false$/) }
      end
    end

    context 'set to an invalid setting' do
      let(:params) do
        {
          :stringify_facts => 'invalid',
          :env             => 'production',
        }
      end
      let(:facts) { { :osfamily => 'RedHat' } }

      it 'should fail' do
        expect {
          should contain_class('puppet::agent')
        }.to raise_error(Puppet::Error)
      end
    end
  end

  describe 'sysconfig file' do
    context 'Puppet agent sysconfig file on osfamily RedHat' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) { { :env => 'production' } }

      it { should contain_class('puppet::agent') }

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

      it { should contain_class('puppet::agent') }

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

      it { should contain_class('puppet::agent') }

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

      it { should contain_class('puppet::agent') }

      it { should_not contain_file('puppet_agent_sysconfig') }
    end

    context 'Puppet agent sysconfig file on osfamily Suse' do
      let(:facts) { { :osfamily => 'Suse' } }
      let(:params) { { :env => 'production' } }

      it { should contain_class('puppet::agent') }

      it { should contain_file('puppet_agent_sysconfig').with({
          'path'    => '/etc/sysconfig/puppet',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
      }

      it { should contain_file('puppet_agent_sysconfig').with_content(/^#PUPPET_SERVER=puppet$/) }
    end

    context 'Puppet agent sysconfig file on invalid osfamily' do
      let(:facts) { { :osfamily => 'invalid' } }
      let(:params) { { :env => 'production' } }

      it 'should fail' do
        expect {
          should contain_class('puppet::agent')
        }.to raise_error(Puppet::Error,/puppet::agent supports osfamilies Debian, RedHat, Solaris, and Suse. Detected osfamily is <invalid>./)
      end
    end
  end

  describe 'with symlink_puppet_binary' do
    ['true',true].each do |value|
      context "set to #{value} (default)" do
        let(:facts) { { :osfamily => 'Debian' } }
        let(:params) do
          { :env                   => 'production',
            :symlink_puppet_binary => value,
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
    end

    ['false',false].each do |value|
      context "set to #{value} (default)" do
        let(:facts) { { :osfamily => 'Debian' } }
        let(:params) do
          { :env                   => 'production',
            :symlink_puppet_binary => value,
          }
        end

        it { should_not contain_file('puppet_symlink') }
      end
    end

    context 'enabled with all params specified' do
      let(:facts) { { :osfamily => 'Debian' } }
      let(:params) do
        { :env                          => 'production',
          :symlink_puppet_binary        => true,
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

    context 'enabled with invalid puppet_binary' do
      let(:params) { {:env => 'production',
                      :symlink_puppet_binary => true,
                      :puppet_binary => 'true',
                      :symlink_puppet_binary_target => '/bar' } }
      it do
        expect { should }.to raise_error(Puppet::Error)
      end
    end

    context 'enabled with invalid symlink_puppet_binary_target' do
      let(:params) { {:env => 'production',
                      :symlink_puppet_binary => true,
                      :puppet_binary => '/foo/bar',
                      :symlink_puppet_binary_target => 'undef' } }
      it do
        expect { should }.to raise_error(Puppet::Error)
      end
    end
  end

  describe 'with run_method' do
    context 'set to disable' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        { :run_method => 'disable',
          :env        => 'production',
        }
      end

      it { should contain_class('puppet::agent') }

      it { should contain_cron('puppet_agent').with({
          'ensure' => 'absent'
        })
      }

      it { should_not contain_cron('puppet_agent_once_at_boot') }

      it { should contain_service('puppet_agent_daemon').with({
          'enable' => false,
        })
      }
    end

    context 'set to service' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        { :run_method => 'service',
          :env        => 'production',
        }
      end

      it { should contain_class('puppet::agent') }

      it { should contain_cron('puppet_agent').with({
          'ensure' => 'absent'
        })
      }

      it { should_not contain_cron('puppet_agent_once_at_boot') }

      it { should contain_service('puppet_agent_daemon').with({
          'enable' => true,
        })
      }
    end

    context 'set to cron' do

      context 'with run_in_noop set to non-string and non-boolean' do
        let(:facts) { { :osfamily => 'RedHat' } }
        let(:params) do
          { :run_method  => 'cron',
            :env         => 'production',
            :run_in_noop => ['invalid_type','not_a_string','not_a_boolean'],
          }
        end

        it 'should fail' do
          expect {
            should contain_class('puppet::agent')
          }.to raise_error(Puppet::Error)
        end

      end

      context 'with run_in_noop set to invalid string' do
        let(:facts) { { :osfamily => 'RedHat' } }
        let(:params) do
          { :run_method  => 'cron',
            :env         => 'production',
            :run_in_noop => 'invalid_string',
          }
        end

        it 'should fail' do
          expect {
            should contain_class('puppet::agent')
          }.to raise_error(Puppet::Error)
        end
      end

      cron_command = '/usr/bin/puppet agent --onetime --ignorecache --no-daemonize --no-usecacheonfailure --detailed-exitcodes --no-splay'

      # iterate through a matrix of setting true and false as booleans and
      # strings for both run_in_noop and run_at_boot.
      ['true',true,'false',false].each do |rin_value|
        context "with run_in_noop => #{rin_value}" do
          ['true',true,'false',false].each do |rab_value|
            context "and run_at_boot => #{rab_value}" do
              let(:facts) { { :osfamily => 'RedHat' } }
              let(:params) do
                { :run_method  => 'cron',
                  :env         => 'production',
                  :run_in_noop => rin_value,
                  :run_at_boot => rab_value,
                }
              end

              if rin_value == true or rin_value == 'true' then
                command = "#{cron_command} --noop"
              else
                command = cron_command
              end

              if rab_value == true or rab_value == 'true' then
                at_boot_ensure = 'present'
              else
                at_boot_ensure = 'absent'
              end

              it { should contain_class('puppet::agent') }

              it {
               should contain_cron('puppet_agent').with({
                  'ensure'  => 'present',
                  'user'    => 'root',
                  'command' => command,
                })
              }

              it { should contain_cron('puppet_agent_once_at_boot').with({
                  'ensure'  => at_boot_ensure,
                  'user'    => 'root',
                  'command' => command,
                  'special' => 'reboot',
                })
              }
            end
          end
        end
      end
    end
  end

  describe 'with puppet_masterport' do
    context 'set to integer' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        { :puppet_masterport => '8888',
          :env               => 'production',
        }
      end

      it { should contain_class('puppet::agent') }
      it { should contain_file('puppet_config').with_content(/^\s*masterport = 8888$/) }
    end

    context 'set to a string that is not an integer (foo)' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        { :puppet_masterport => 'foo',
          :env               => 'production',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('puppet::agent')
        }.to raise_error(Puppet::Error,/puppet::agent::puppet_masterport is set to <foo>. It should be an integer./)
      end
    end

    context 'set to an invalid type (non-string)' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        { :puppet_masterport => ['invalid','type'],
          :env               => 'production',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('puppet::agent')
        }.to raise_error(Puppet::Error)
      end
    end
  end

  describe 'with etckeeper_hooks' do
    ['true',true].each do |value|
      context "set to #{value}" do
        let(:params) do
          {
            :etckeeper_hooks => value,
            :env             => 'production',
          }
        end
        let(:facts) { { :osfamily => 'RedHat' } }

          it { should contain_file('etckeeper_pre') }
          it { should contain_file('etckeeper_post') }
          it { should contain_file('puppet_config').with_content(/^\s*prerun_command=\/etc\/puppet\/etckeeper-commit-pre$/) }
          it { should contain_file('puppet_config').with_content(/^\s*postrun_command=\/etc\/puppet\/etckeeper-commit-post$/) }
      end
    end

    ['false',false].each do |value|
      context "set to #{value}" do
        let(:params) do
          {
            :etckeeper_hooks => value,
            :env             => 'production',
          }
        end
        let(:facts) { { :osfamily => 'RedHat' } }

        it { should_not contain_file('etckeeper_pre') }
        it { should_not contain_file('etckeeper_post') }
        it { should_not contain_file('puppet_config').with_content(/^\s*prerun_command=\/etc\/puppet\/etckeeper-commit-pre$/) }
        it { should_not contain_file('puppet_config').with_content(/^\s*postrun_command=\/etc\/puppet\/etckeeper-commit-post$/) }
      end
    end

    context 'set to an invalid setting' do
      let(:params) do
        {
          :etckeeper_hooks => 'invalid',
          :env             => 'production',
        }
      end
      let(:facts) { { :osfamily => 'RedHat' } }

      it 'should fail' do
        expect {
          should contain_class('puppet::agent')
        }.to raise_error(Puppet::Error)
      end
    end
  end

  describe 'with http_proxy_host' do
    context 'set to a valid domain' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        { :http_proxy_host => 'proxy.host.local.domain',
          :env             => 'production',
        }
      end
      it { should contain_class('puppet::agent') }
      it {should contain_file('puppet_config').with_content(/^\s*http_proxy_host = proxy\.host\.local\.domain$/) }
    end

    ['8.8.8.8','2a00:1450:400f:804::1011'].each do |ip_address|
      context "set to #{ip_address} (ip-address)" do
        let(:facts) { { :osfamily => 'RedHat' } }
        let(:params) do
          { :env                   => 'production',
            :http_proxy_host       => ip_address,
          }
        end

        it { should contain_file('puppet_config').with_content(/\s*http_proxy_host = #{Regexp.escape(ip_address)}$/) }
      end
    end
    ['8.8.8.8.#','".#.%.!','foo..bar'].each do |invalid_value|
      context "set to #{invalid_value} (invalid value)" do
        let(:facts) { { :osfamily => 'RedHat' } }
        let(:params) do
          { :env                   => 'production',
            :http_proxy_host       => invalid_value,
          }
        end
        it 'should fail' do
          expect {
            should contain_class('puppet::agent')
          }.to raise_error(Puppet::Error,/puppet::agent::http_proxy_host is set to <#{Regexp.escape(invalid_value)}>. It should be a fqdn or an ip-address./)
        end
      end
    end
    context 'set to an invalid type' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        { :http_proxy_host => ['invalid','type'],
          :env             => 'production',
        }
      end
      it 'should fail' do
        expect {
          should contain_class('puppet::agent')
        }.to raise_error(Puppet::Error)
      end
    end
  end


  describe 'with http_proxy_port' do
    context 'set to integer' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        { :http_proxy_port => '8888',
          :env             => 'production',
        }
      end
      it { should contain_class('puppet::agent') }
      it { should contain_file('puppet_config').with_content(/^\s*http_proxy_port = 8888$/) }
    end
    context 'set to an invalid type' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        { :http_proxy_port => ['invalid','type'],
          :env             => 'production',
        }
      end
      it 'should fail' do
        expect {
          should contain_class('puppet::agent')
        }.to raise_error(Puppet::Error)
      end
    end
    context 'set to an invalid value' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) do
        { :http_proxy_port => 'foo',
          :env             => 'production',
        }
      end
      it 'should fail' do
        expect {
          should contain_class('puppet::agent')
        }.to raise_error(Puppet::Error,/puppet::agent::http_proxy_port is set to <foo>. It should be an Integer./)
      end
    end
  end
end
