require_relative "spec_helper"

describe "solum::python" do
  before { solum_stubs }
  describe "ubuntu" do
    before do
      @chef_run = ::ChefSpec::ChefRunner.new ::UBUNTU_OPTS
      @chef_run.converge "solum::python"
    end

    it "includes python recipe" do
      expect(@chef_run).to include_recipe 'python'
    end

    it "installs the deadsnakes repo for extra pythons" do
      resource = @chef_run.find_resource(
        'apt_repository',
        'deadsnakes'
      ).to_hash
      expect(resource).to include(
        :uri   => 'http://ppa.launchpad.net/fkrull/deadsnakes/ubuntu/',
        :action         => [:add]
      )
    end

    ['python-gdbm', 'python2.6', 'python2.7', 'python3.3', 'pypy-dev'].each do |pkg|
      it "Installs package #{pkg}" do
        expect(@chef_run).to install_package(pkg)
      end
    end

  end
end
