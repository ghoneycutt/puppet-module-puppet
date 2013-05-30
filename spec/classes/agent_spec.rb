require 'spec_helper'
describe 'puppet::agent' do

  describe 'class puppet::agent' do

    context 'run method setup' do
      let(:params) { {:run_method => 'service',
                      :env => 'production' } }
      it {
        should include_class('puppet::agent')
        should contain_cron('puppet_agent').with({
          'ensure' => 'absent',
        })
      }
    end
  end
end
