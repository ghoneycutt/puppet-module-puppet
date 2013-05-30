require 'spec_helper'
describe 'puppet::lint' do

  describe 'class puppet::lint' do

    context 'package installation' do
      let(:params) { {:provider => 'gem' } }
      it {
        should include_class('puppet::lint')
        should contain_package('puppet-lint').with({
          'provider' => 'gem',
        })
      }
    end

    context 'config file location' do
      let(:params) { {:lintrc_path => '/root/.puppet-lint.rc',
                      :lintrc_owner => 'root'} }
      it {
        should include_class('puppet::lint')
        should contain_file('/root/.puppet-lint.rc').with({
          'owner' => 'root',
        })
      }
    end

  end
end
