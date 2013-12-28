require 'spec_helper'

describe 'puppet::master::maintenance' do

  describe 'class puppet::master::maintenance' do

    context 'Puppetmaster maintenance cron' do
      it { should contain_class('puppet::master::maintenance') }
      it { should contain_cron('filebucket_cleanup').with({
          'user'    => 'root',
          'hour'    => '0',
          'minute'  => '0',
        })
      }
    end
  end
end
