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

    context 'Puppetmaster sysconfig file' do
      let(:facts) { {:osfamily => 'redhat',
                     :operatingsystemrelease => '6.4',
                     :concat_basedir => '/tmp' } }
      it {
        should include_class('puppet::master')
        should contain_file('/etc/sysconfig/puppetmaster') \
               .with_content(/^#PUPPETMASTER_LOG=syslog$/)
      }
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
