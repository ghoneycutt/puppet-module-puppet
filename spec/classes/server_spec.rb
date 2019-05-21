require 'spec_helper'
describe 'puppet::server' do

  ca_config_if_true = <<-END.gsub(/^\s+\|/, '')
    |# This file is being maintained by Puppet.
    |# DO NOT EDIT
    |
    |# To enable the CA service, leave the following line uncommented
    |puppetlabs.services.ca.certificate-authority-service/certificate-authority-service
    |# To disable the CA service, comment out the above line and uncomment the line below
    |#puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service
  END

  ca_config_if_false = <<-END.gsub(/^\s+\|/, '')
    |# This file is being maintained by Puppet.
    |# DO NOT EDIT
    |
    |# To enable the CA service, leave the following line uncommented
    |#puppetlabs.services.ca.certificate-authority-service/certificate-authority-service
    |# To disable the CA service, comment out the above line and uncomment the line below
    |puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service
  END

  # Filter out duplicate platforms
  platforms = on_supported_os.select { |k, _v| !k.to_s.match(/^(RedHat|Scientific|OracleLinux)/i) }

  platforms.each do |os, facts|
    context "on #{os} with default values for parameters" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }
      it { should contain_class('puppet') }
      it { should contain_class('puppet::server') }

      non_conditional_ini_settings = {
        'vardir'  => '/opt/puppetlabs/server/data/puppetserver',
        'logdir'  => '/var/log/puppetlabs/puppetserver',
        'rundir'  => '/var/run/puppetlabs/puppetserver',
        'pidfile' => '/var/run/puppetlabs/puppetserver/puppetserver.pid',
        'codedir' => '/etc/puppetlabs/code',
        'ca'      => false,
      }

      non_conditional_ini_settings.each do |setting, value|
        it do
          should contain_ini_setting(setting).with({
            :ensure  => 'present',
            :setting => setting,
            :value   => value,
            :path    => '/etc/puppetlabs/puppet/puppet.conf',
            :section => 'master',
            :require => 'File[puppet_config]',
            :notify  => 'Service[puppetserver]',
          })
        end
      end

      %w(node_terminus external_nodes).each do |setting|
        it { should_not contain_ini_setting(setting) }
      end

      empty_autosign_content = <<-END.gsub(/^\s+\|/, '')
        |# This file is being maintained by Puppet.
        |# DO NOT EDIT
      END

      it do
        should contain_file('autosign_config').with({
          :ensure  => 'file',
          :path    => '/etc/puppetlabs/puppet/autosign.conf',
          :content => empty_autosign_content,
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0644',
          :notify  => 'Service[puppetserver]',
        })
      end

      it do
        should contain_file('puppetserver_ca_cfg').with({
          :ensure  => 'file',
          :path    => '/etc/puppetlabs/puppetserver/services.d/ca.cfg',
          :content => ca_config_if_false,
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0644',
          :notify  => 'Service[puppetserver]',
        })
      end

      puppetserver_sysconfig = File.read(fixtures('puppetserver_sysconfig'))
      it do
        should contain_file('puppetserver_sysconfig').with({
          :ensure  => 'file',
          :path    => '/etc/sysconfig/puppetserver',
          :content => puppetserver_sysconfig,
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0644',
        })
      end

      it do
        should contain_service('puppetserver').with({
          :ensure    => 'running',
          :enable    => true,
          :subscribe => [
            'File[puppet_config]',
            'File[puppetserver_sysconfig]',
          ],
        })
      end
    end
  end

  describe 'with ca' do
    [true, 'true'].each do |value|
      context "set to #{value} (as #{value.class})" do
        let(:params) { { :ca => value } }

        it do
          should contain_file('puppetserver_ca_cfg').with({
            :content => ca_config_if_true,
          })
        end

        it do
          should contain_ini_setting('ca').with({
            :setting => 'ca',
            :value   => true,
          })
        end
      end
    end

    [false, 'false'].each do |value|
      context "set to #{value} (as #{value.class})" do
        let(:params) { { :ca => value } }

        it do
          should contain_file('puppetserver_ca_cfg').with({
            :content => ca_config_if_false,
          })
        end

        it do
          should contain_ini_setting('ca').with({
            :setting => 'ca',
            :value   => false,
          })
        end
      end
    end
  end

  describe 'with enc' do
    context 'set to a valid path' do
      let(:params) { { :enc => '/path/to/enc' } }

      it do
        should contain_ini_setting('external_nodes').with({
          :ensure  => 'present',
          :setting => 'external_nodes',
          :value   => '/path/to/enc',
          :path    => '/etc/puppetlabs/puppet/puppet.conf',
          :section => 'master',
          :require => 'File[puppet_config]',
          :notify  => 'Service[puppetserver]',
        })
      end

      it do
        should contain_ini_setting('node_terminus').with({
          :ensure  => 'present',
          :setting => 'node_terminus',
          :value   => 'exec',
          :path    => '/etc/puppetlabs/puppet/puppet.conf',
          :section => 'master',
          :require => 'File[puppet_config]',
          :notify  => 'Service[puppetserver]',
        })
      end
    end
  end

  describe 'with autosign_entries' do
    context 'set to a valid array of strings' do
      let(:params) { { :autosign_entries => ['*.example.org', '*.dev.example.org'] } }

      autosign_conf_content = <<-END.gsub(/^\s+\|/, '')
        |# This file is being maintained by Puppet.
        |# DO NOT EDIT
        |*.example.org
        |*.dev.example.org
      END

      it { should contain_file('autosign_config').with_content(autosign_conf_content) }
    end
  end

  describe 'parameter type and content validations' do
    validations = {
      'absolute paths' => {
        :name    => %w(sysconfig_path enc),
        :valid   => ['/absolute/path'],
        :invalid => ['not/an/absolute/path'],
        :message => 'is not an absolute path',
      },
      'booleans' => {
        :name    => %w(ca),
        :valid   => [true, 'true', false, 'false'],
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42],
        :message => 'Error while evaluating a Resource Statement',
      },
      'non-empty array of strings' => {
        :name    => %w(autosign_entries),
        :valid   => [['array with one string'], %w(array with many strings)],
        :invalid => [%w(), [1, 'not_all', 'string'], true, 'string', { 'ha' => 'sh' }, 3, 2.42],
        :message => 'Error while evaluating a Resource Statement',
      },
      'memory size regex' => {
        :name    => %w(memory_size),
        :valid   => %w(1g 1m 1500m 3g),
        :invalid => ['1g1', 'm', '1k', '2t', 'g3', '1.2g'],
        :message => 'must be an integer following by the unit',
      },
    }

    validations.sort.each do |type, var|
      var[:name].each do |var_name|
        var[:params] = {} if var[:params].nil?
        var[:valid].each do |valid|
          context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
            let(:params) { [var[:params], { :"#{var_name}" => valid, }].reduce(:merge) }
            it { should compile }
          end
        end

        var[:invalid].each do |invalid|
          context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { [var[:params], { :"#{var_name}" => invalid, }].reduce(:merge) }
            it 'should fail' do
              expect { should contain_class(subject) }.to raise_error(Puppet::Error, /#{var[:message]}/)
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'parameter type content validations'
end
