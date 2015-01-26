require 'spec_helper'
describe 'puppet::passenger' do

  describe 'class puppet::passenger' do

    context 'Puppetmaster passenger configuration file with default parameters' do
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :concat_basedir         => '/tmp',
          :puppet_reportdir       => '/var/lib/puppet/reports',
          :fqdn                   => 'my_fqdn.example.com',
          :processorcount         => 4,
        }
      end

      it { should contain_class('puppet::passenger') }

      puppetmaster_fixture = File.read(fixtures("passenger_extra.conf.default"))
      it { should contain_file('passenger.conf').with_content(puppetmaster_fixture) }
    end

    context 'Puppetmaster passenger configuration file with custom parameters' do
      let(:facts) do
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :concat_basedir         => '/tmp',
          :puppet_reportdir       => '/var/lib/puppet/reports',
          :fqdn                   => 'my_fqdn.example.com',
          :processorcount         => 4,
        }
      end
      let(:params) do
        { :passenger_high_performance => 'off',
          :passenger_max_pool_size => '2',
          :passenger_max_requests => '500',
          :passenger_pool_idle_time => '300',
          :passenger_stat_throttle_rate => '60',
          :passenger_use_global_queue => 'off',
          :rack_autodetect => 'off',
          :rails_autodetect => 'off',
        }
      end

      it { should contain_class('puppet::passenger') }

      puppetmaster_fixture = File.read(fixtures("passenger_extra.conf.custom"))
      it { should contain_file('passenger.conf').with_content(puppetmaster_fixture) }
    end
  end
end
