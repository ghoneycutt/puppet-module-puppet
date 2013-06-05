require 'spec_helper'
describe 'puppet::master::maintenance' do

  describe 'class puppet::master::maintenance' do

    context 'Puppetmaster maintenance cron' do
      it {
        should include_class('puppet::master::maintenance')
        should contain_cron('filebucket_cleanup').with({
          'user'    => 'root',
          'hour'    => '0',
          'minute'  => '0',
        })
      }
    end
  end
end
