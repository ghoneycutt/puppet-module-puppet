require 'spec_helper'
describe 'puppet::server' do
  # Filter out duplicate platforms
  platforms = on_supported_os.reject { |k, _v| k.to_s.match(%r{^(RedHat|Scientific|OracleLinux)}i) }

  platforms.each do |os, facts|
    context "on #{os} with default values for parameters" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('puppet') }
      it { is_expected.to contain_class('puppet::server') }

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
          is_expected.to contain_ini_setting(setting).with(
            {
              ensure:  'present',
              setting: setting,
              value:   value,
              path:    '/etc/puppetlabs/puppet/puppet.conf',
              section: 'master',
              require: 'File[puppet_config]',
              notify:  'Service[puppetserver]',
            },
          )
        end
      end

      ['node_terminus', 'external_nodes', 'dns_alt_names'].each do |setting|
        it { is_expected.not_to contain_ini_setting(setting) }
      end

      empty_autosign_content = <<-END.gsub(%r{^\s+\|}, '')
        |# This file is being maintained by Puppet.
        |# DO NOT EDIT
      END

      it do
        is_expected.to contain_file('autosign_config').with(
          {
            ensure:  'file',
            path:    '/etc/puppetlabs/puppet/autosign.conf',
            content: empty_autosign_content,
            owner:   'root',
            group:   'root',
            mode:    '0644',
            notify:  'Service[puppetserver]',
          },
        )
      end

      puppetserver_sysconfig = File.read(fixtures('puppetserver_sysconfig'))
      it do
        is_expected.to contain_file('puppetserver_sysconfig').with(
          {
            ensure:  'file',
            path:    '/etc/sysconfig/puppetserver',
            content:  puppetserver_sysconfig,
            owner:    'root',
            group:    'root',
            mode:     '0644',
          },
        )
      end

      it do
        is_expected.to contain_service('puppetserver').with(
          {
            ensure:    'running',
            enable:    true,
            subscribe: [
              'File[puppet_config]',
              'File[puppetserver_sysconfig]',
            ],
          },
        )
      end
    end
  end

  describe 'with ca' do
    [true, false].each do |value|
      context "set to #{value} (as #{value.class})" do
        let(:params) { { ca: value } }

        it do
          is_expected.to contain_ini_setting('ca').with(
            {
              ensure:  'present',
              setting: 'ca',
              value:   value,
              path:    '/etc/puppetlabs/puppet/puppet.conf',
              section: 'master',
              require: 'File[puppet_config]',
              notify:  'Service[puppetserver]',
            },
          )
        end
      end
    end
  end

  describe 'with enc' do
    context 'set to a valid path' do
      let(:params) { { enc: '/path/to/enc' } }

      it do
        is_expected.to contain_ini_setting('external_nodes').with(
          {
            ensure:  'present',
            setting: 'external_nodes',
            value:   '/path/to/enc',
            path:    '/etc/puppetlabs/puppet/puppet.conf',
            section: 'master',
            require: 'File[puppet_config]',
            notify:  'Service[puppetserver]',
          },
        )
      end

      it do
        is_expected.to contain_ini_setting('node_terminus').with(
          {
            ensure:  'present',
            setting: 'node_terminus',
            value:   'exec',
            path:    '/etc/puppetlabs/puppet/puppet.conf',
            section: 'master',
            require: 'File[puppet_config]',
            notify:  'Service[puppetserver]',
          },
        )
      end
    end
  end

  describe 'with dns_alt_names' do
    context 'set to a valid path' do
      let(:params) { { dns_alt_names: 'foo,foo1,foo1.example.com,foo.example.com' } }

      it do
        is_expected.to contain_ini_setting('dns_alt_names').with(
          {
            ensure:  'present',
            setting: 'dns_alt_names',
            value:   'foo,foo1,foo1.example.com,foo.example.com',
            path:    '/etc/puppetlabs/puppet/puppet.conf',
            section: 'master',
            require: 'File[puppet_config]',
            notify:  'Service[puppetserver]',
          },
        )
      end
    end
  end

  describe 'with autosign_entries' do
    context 'set to a valid array of strings' do
      let(:params) { { autosign_entries: ['*.example.org', '*.dev.example.org'] } }

      autosign_conf_content = <<-END.gsub(%r{^\s+\|}, '')
        |# This file is being maintained by Puppet.
        |# DO NOT EDIT
        |*.example.org
        |*.dev.example.org
      END

      it { is_expected.to contain_file('autosign_config').with_content(autosign_conf_content) }
    end
  end

  describe 'parameter type and content validations' do
    validations = {
      'Stdlib::Absolutepath' => {
        name:    ['sysconfig_path', 'enc'],
        valid:   ['/absolute/path'],
        invalid: ['not/an/absolute/path'],
        message: 'expects a Stdlib::Absolutepath',
      },
      'Boolean' => {
        name:    ['ca'],
        valid:   [true, false],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, 3, 2.42],
        message: 'expects a Boolean',
      },
      'strings' => {
        name:    ['dns_alt_names'],
        valid:   ['string'],
        invalid: [true, ['array'], { 'ha' => 'sh' }, 3, 2.42],
        message: 'Error while evaluating a Resource Statement',
      },
      'non-empty array of strings' => {
        name:    ['autosign_entries'],
        valid:   [['array with one string'], ['array', 'with', 'many', 'strings']],
        invalid: [[], [1, 'not_all', 'string'], true, 'string', { 'ha' => 'sh' }, 3, 2.42],
        message: 'Error while evaluating a Resource Statement',
      },
      'Pattern[/^\d+(m|g)$/]' => {
        name:    ['memory_size'],
        valid:   ['1g', '1m', '1500m', '3g'],
        invalid: ['1g1', 'm', '1k', '2t', 'g3', '1.2g'],
        message: 'expects a match for Pattern',
      },
    }

    validations.sort.each do |type, var|
      var[:name].each do |var_name|
        var[:params] = {} if var[:params].nil?
        var[:valid].each do |valid|
          context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
            let(:params) { [var[:params], { "#{var_name}": valid, }].reduce(:merge) }

            it { is_expected.to compile }
          end
        end

        var[:invalid].each do |invalid|
          context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { [var[:params], { "#{var_name}": invalid, }].reduce(:merge) }

            it 'is_expected.to fail' do
              expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{#{var[:message]}})
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'parameter type content validations'
end
