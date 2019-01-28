require 'spec_helper'
describe 'puppet' do
  # fqdn_rand() entries will always return this
  minute = [2, 32]

  # Filter out duplicate platforms
  platforms = on_supported_os.select { |k, _v| !k.to_s.match(/^(RedHat|Scientific|OracleLinux)/i) }

  platforms.each do |os, facts|
    context "on #{os} with default values for parameters" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }
      it { should contain_class('puppet') }

      it { should_not contain_file('puppetserver_sysconfig') }
      it { should_not contain_service('puppetserver') }
      it { should_not contain_class('puppet::server') }

      it do
        should contain_cron('puppet_agent_every_thirty').with({
          :ensure  => 'present',
          :command => '/opt/puppetlabs/bin/puppet agent --onetime --no-daemonize --no-usecacheonfailure --detailed-exitcodes --no-splay --noop',
          :user    => 'root',
          :hour    => '*',
          #:minute  => [16,46],
          :minute  => minute,
        })
      end

      it do
        should contain_cron('puppet_agent_once_at_boot').with({
          :ensure  => 'present',
          :command => '/opt/puppetlabs/bin/puppet agent --onetime --no-daemonize --no-usecacheonfailure --detailed-exitcodes --no-splay --noop',
          :user    => 'root',
          :special => 'reboot',
        })
      end

      ini_settings = {
        'server'              => 'puppet',
        'ca_server'           => 'puppet',
        'certname'            => 'puppet.example.com',
        'environment'         => 'rp_env',
        'trusted_node_data'   => true,
        'graph'               => false,
      }

      ini_settings.each do |setting, value|
        it do
          should contain_ini_setting(setting).with({
            :ensure  => 'present',
            :setting => setting,
            :value   => value,
            :path    => '/etc/puppetlabs/puppet/puppet.conf',
            :section => 'main',
            :require => 'File[puppet_config]',
          })
        end
      end

      it do
        should contain_file('puppet_config').with({
          :ensure  => 'file',
          :path    => '/etc/puppetlabs/puppet/puppet.conf',
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0644',
        })
      end

      puppet_agent_sysconfig = File.read(fixtures('puppet_agent_sysconfig'))
      it do
        should contain_file('puppet_agent_sysconfig').with({
          :ensure  => 'file',
          :path    => '/etc/sysconfig/puppet',
          :content => puppet_agent_sysconfig,
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0644',
        })
      end

      it do
        should contain_service('puppet_agent_daemon').with({
          :ensure => 'stopped',
          :name   => 'puppet',
          :enable => false,
        })
      end
    end
  end

  describe 'with run_every_thirty' do
    [true, 'true', false, 'false'].each do |value|
      [true, 'true', false, 'false'].each do |noop_value|
        context "set to #{value} (as #{value.class}) and run_in_noop set to #{noop_value} (as #{noop_value.class})" do
          let(:params) do
            {
              :run_every_thirty => value,
              :run_in_noop      => noop_value,
            }
          end

          if [true, 'true'].include?(value)
            cron_ensure = 'present'
            cron_minute = minute
          else
            cron_ensure = 'absent'
            cron_minute = nil
          end

          cron_command = if [true, 'true'].include?(noop_value)
                           '/opt/puppetlabs/bin/puppet agent --onetime --no-daemonize --no-usecacheonfailure --detailed-exitcodes --no-splay --noop'
                         else
                           '/opt/puppetlabs/bin/puppet agent --onetime --no-daemonize --no-usecacheonfailure --detailed-exitcodes --no-splay'
                         end

          it do
            should contain_cron('puppet_agent_every_thirty').with({
              :ensure  => cron_ensure,
              :command => cron_command,
              :user    => 'root',
              :hour    => '*',
              :minute  => cron_minute,
            })
          end
        end
      end
    end
  end

  describe 'with cron_command specified' do
    context 'and run_in_noop set to true' do
      let(:params) do
        {
          :run_in_noop => true,
          :cron_command => '/some/command'
        }
      end

      it { should contain_cron('puppet_agent_every_thirty').with_command('/some/command --noop') }
      it { should contain_cron('puppet_agent_once_at_boot').with_command('/some/command --noop') }
    end

    context 'and run_in_noop set to false' do
      let(:params) do
        {
          :run_in_noop => false,
          :cron_command => '/some/command'
        }
      end

      it { should contain_cron('puppet_agent_every_thirty').with_command('/some/command') }
      it { should contain_cron('puppet_agent_once_at_boot').with_command('/some/command') }
    end
  end

  describe 'with run_at_boot' do
    [true, 'true', false, 'false'].each do |value|
      context "set to #{value} (as #{value.class})" do
        let(:params) { { :run_at_boot => value } }

        foo = if [true, 'true'].include?(value)
                'present'
              else
                'absent'
              end

        it { should contain_cron('puppet_agent_once_at_boot').with_ensure(foo) }
      end
    end
  end

  describe 'with config_path specified' do
    let(:params) { { :config_path => '/path/to/puppet.conf' } }

    it { should contain_file('puppet_config').with_path('/path/to/puppet.conf') }

    ini_settings = %w(server ca_server certname environment trusted_node_data graph)

    ini_settings.each do |setting|
      it { should contain_ini_setting(setting).with_path('/path/to/puppet.conf') }
    end
  end

  describe 'with puppet.conf ini setting' do
    %w(server ca_server certname graph).each do |setting|
      context "#{setting} set to a valid entry" do
        # 'true' is used because it is acceptable to all of the above
        # parameters. Some of the settings are strings and some are boolean and
        # stringified booleans.
        let(:params) { { setting => 'true' } }

        it do
          should contain_ini_setting(setting).with({
            :ensure  => 'present',
            :setting => setting,
            :value   => 'true',
            :path    => '/etc/puppetlabs/puppet/puppet.conf',
            :section => 'main',
            :require => 'File[puppet_config]',
          })
        end
      end
    end
  end

  describe 'with env specified' do
    let(:params) { { :env => 'myenv' } }

    it do
      should contain_ini_setting('environment').with({
        :ensure  => 'present',
        :setting => 'environment',
        :value   => 'myenv',
        :path    => '/etc/puppetlabs/puppet/puppet.conf',
        :section => 'main',
        :require => 'File[puppet_config]',
      })
    end
  end

  describe 'without env specified' do
    it do
      should contain_ini_setting('environment').with({
        :ensure  => 'present',
        :setting => 'environment',
        :value   => 'rp_env',
        :path    => '/etc/puppetlabs/puppet/puppet.conf',
        :section => 'main',
        :require => 'File[puppet_config]',
      })
    end
  end

  describe 'with server specified' do
    let(:params) { { :server => 'foo' } }

    it do
      should contain_ini_setting('server').with({
        :ensure  => 'present',
        :setting => 'server',
        :value   => 'foo',
        :path    => '/etc/puppetlabs/puppet/puppet.conf',
        :section => 'main',
        :require => 'File[puppet_config]',
      })
    end
  end

  describe 'with custom_settings specified' do
    let(:params) { {
      :custom_settings => {
        'codedir' => { 'section' => 'master', 'setting' => 'codedir', 'value' => '/spec/testing' },
        'testing' => { 'section' => 'agent',  'setting' => 'server',  'value' => 'spec.test.ing' },
      }
    } }

    it do
      should contain_ini_setting('codedir').with({
        :ensure  => 'present',
        :path    => '/etc/puppetlabs/puppet/puppet.conf',
        :section => 'master',
        :setting => 'codedir',
        :value   => '/spec/testing',
        :require => 'File[puppet_config]',
      })
    end

    it do
      should contain_ini_setting('testing').with({
        :ensure  => 'present',
        :path    => '/etc/puppetlabs/puppet/puppet.conf',
        :section => 'agent',
        :setting => 'server',
        :value   => 'spec.test.ing',
        :require => 'File[puppet_config]',
      })
    end
  end

  describe 'parameter type and content validations' do
    validations = {
      'absolute paths' => {
        :name    => %w(config_path agent_sysconfig_path),
        :valid   => ['/absolute/path'],
        :invalid => ['not/an/absolute/path'],
        :message => 'is not an absolute path',
      },
      'booleans' => {
        :name    => %w(run_every_thirty run_in_noop run_at_boot graph),
        :valid   => [true, 'true', false, 'false'],
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42],
        :message => 'Error while evaluating a Resource Statement',
      },
      'hash' => {
        :name    => %w(custom_settings),
        :valid   => [], # valid hashes are to complex to block test them here
        :invalid => ['string', %w(array), 3, 2.42, true, nil],
        :message => 'expects a Hash value',
      },
      'strings' => {
        :name    => %w(certname cron_command server ca_server env),
        :valid   => ['string'],
        :invalid => [true, %w(array), { 'ha' => 'sh' }, 3, 2.42],
        :message => 'Error while evaluating a Resource Statement',
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
