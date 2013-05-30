require 'spec_helper'
describe 'puppet::master' do

  describe 'class puppet::master' do

    context 'rack dir' do
      let(:params) { {:rack_dir => '/foo/bar' } }
      let(:facts) { {:osfamily => 'redhat',
                     :operatingsystemrelease => '6.4',
                     :concat_basedir => '/tmp' } }
      it {
        should include_class('puppet::master')
        should contain_file('/foo/bar').with({
          'ensure' => 'directory',
        })
      }
    end
  end
end
