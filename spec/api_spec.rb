require_relative "spec_helper"

describe "solum::api" do
  before { solum_stubs }
  describe "ubuntu" do
    before do
      @chef_run = ::ChefSpec::ChefRunner.new ::UBUNTU_OPTS
      @chef_run.converge "solum::api"
    end

    it "includes solum::python recipe" do
      expect(@chef_run).to include_recipe 'solum::python'
    end

    describe "lwrps" do
      ['pecan', 'WSME', 'tox', 'pep8'].each do |pip|
        it "installs python package #{pip}" do
          resource = @chef_run.find_resource(
            'python_pip',
            pip
          ).to_hash
          expect(resource).to include(
            :package_name   => pip,
            :action         => [:install]
          )
        end
      end
    end
  end
end
