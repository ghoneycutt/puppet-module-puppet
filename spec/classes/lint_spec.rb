require 'spec_helper'
describe 'puppet::lint' do

  describe 'class puppet::lint' do

    context 'Puppet Lint package' do
      let(:params) { {:provider => 'gem' } }
      it {
        should include_class('puppet::lint')
        should contain_package('puppet-lint').with({
          'provider' => 'gem',
        })
      }
    end

    context 'Puppet Lint configuration file' do
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
