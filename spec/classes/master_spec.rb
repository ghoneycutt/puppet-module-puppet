require 'spec_helper'
describe 'puppet::master' do

  describe 'class puppet::master' do

    context 'Puppetmaster auth.conf configuration file' do
      let(:facts) { {:osfamily => 'redhat',
                     :operatingsystemrelease => '6.4',
                     :concat_basedir => '/tmp' } }
      it {
        should include_class('puppet::master')
        should contain_file('/etc/puppet/auth.conf').with({
          'owner' => 'root',
        })
      }
    end

    context 'Puppetmaster fileserver.conf configuration file' do
      let(:facts) { {:osfamily => 'redhat',
                     :operatingsystemrelease => '6.4',
                     :concat_basedir => '/tmp' } }
      it {
        should include_class('puppet::master')
        should contain_file('/etc/puppet/fileserver.conf').with({
          'owner' => 'root',
        })
      }
    end

    context 'Puppetmaster sysconfig file on osfamily RedHat' do
      let(:facts) {
        { :osfamily               => 'RedHat',
          :operatingsystemrelease => '6.4',
          :concat_basedir         => '/tmp',
        }
      }

      it { should include_class('puppet::master') }
      it { should contain_file('puppetmaster_sysconfig').with_content(/^#PUPPETMASTER_LOG=syslog$/) }
    end

    context 'Puppetmaster sysconfig file on osfamily Debian' do
      let(:facts) {
        { :osfamily               => 'Debian',
          :operatingsystemrelease => '7',
          :concat_basedir         => '/tmp',
        }
      }

      it { should include_class('puppet::master') }
      it { should contain_file('puppetmaster_sysconfig').with_content(/^#PUPPETMASTER_LOG=syslog$/) }
    end

    context 'Puppetmaster sysconfig file on invalid osfmaily' do
      let(:facts) {
        { :osfamily               => 'invalid',
          :operatingsystemrelease => '6.4',
          :concat_basedir         => '/tmp',
        }
      }

      it 'should fail' do
        expect {
          should include_class('puppet::master')
        }.to raise_error(Puppet::Error,/puppet::master supports osfamilies Debian and RedHat. Detected osfamily is <invalid>./)
      end
    end

    context 'Puppetmaster rack directory' do
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

    context 'Puppetmaster rack configuration file' do
      let(:params) { {:rack_dir => '/foo/bar' } }
      let(:facts) { {:osfamily => 'redhat',
                     :operatingsystemrelease => '6.4',
                     :concat_basedir => '/tmp' } }
      it {
        should include_class('puppet::master')
        should contain_file('/foo/bar/config.ru').with({
          'owner'   => 'puppet',
          'group'   => 'root',
          'mode'    => '0644',
        })
      }
    end

    context 'Puppetmaster vhost configuration file' do
      let(:facts) { {:osfamily => 'redhat',
                     :operatingsystemrelease => '6.4',
                     :concat_basedir => '/tmp' } }
      it {
        should include_class('puppet::master')
        should contain_file('puppetmaster_vhost').with({
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        })
      }
    end

    context 'Puppetmaster vhost configuration file content' do
      let(:facts) { {:osfamily => 'redhat',
                     :operatingsystemrelease => '6.4',
                     :concat_basedir => '/tmp' } }
      it {
        should include_class('puppet::master')
        should contain_file('puppetmaster_vhost') \
               .with_content(/^\s*<Directory \/usr\/share\/puppet\/rack\/puppetmasterd\/>$/)
      }
    end
  end
end
