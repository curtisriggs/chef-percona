require "spec_helper"

describe "percona::package_repo" do
  describe "Ubuntu" do
    let(:chef_run) do
      ChefSpec::SoloRunner.new.converge(described_recipe)
    end

    it "sets up an apt repository for `percona`" do
      expect(chef_run).to add_apt_repository("percona")
    end

    context 'apt_repository[percona]' do
      subject { chef_run.apt_repository('percona') }
      describe "default parameters" do
        it { is_expected.to have_attributes(keyserver: 'hkp://keys.gnupg.net:80') }
        it { is_expected.to have_attributes(key: '0x1C4CBDCDCD2EFD2A') }
        it { is_expected.to have_attributes(uri: 'http://repo.percona.com/apt') }
        it { is_expected.to have_attributes(key_proxy: '') }
      end

      describe "setting percona.apt.keyserver" do
        before do
          chef_run.node.override['percona']['apt']['keyserver'] = 'alt-keys.gnupg.net'
          chef_run.converge(described_recipe)
        end
        subject { chef_run.apt_repository('percona') }
        it { is_expected.to have_attributes(keyserver: 'alt-keys.gnupg.net') }
      end

      describe "setting percona.apt.key_proxy" do
        before do
          chef_run.node.override['percona']['apt']['key_proxy'] = 'http://myproxy:8080'
          chef_run.converge(described_recipe)
        end
        subject { chef_run.apt_repository('percona') }
        it { is_expected.to have_attributes(key_proxy: 'http://myproxy:8080') }
      end
    end

    it "sets up an apt preference" do
      expect(chef_run).to add_apt_preference("00percona")
    end
  end

  describe "CentOS" do
    let(:chef_run) do
      env_options = { platform: "centos", version: "6.5" }
      ChefSpec::SoloRunner.new(env_options).converge(described_recipe)
    end

    it "sets up a yum repository for `percona`" do
      expect(chef_run).to create_yum_repository("percona")
    end
  end
end
