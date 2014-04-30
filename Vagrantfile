#############################################################################
# This VagrantFile defines two configurations:
#
# Config 1:
# A separate VM for API server, git server, a server for support services
# such as MySQL and RabbitMQ, and DevStack that has Nova with Docker driver
#
# Config 2:
# One VM for DevStack with 'Dockerized' Nova and one VM for the rest of
# the components
#
# Set ENV['DEVSTACK_BRANCH'] to change the devstack branch to use
# Set ENV['SOLUM']='~/dev/solum' path on local system to solum repo
# Set ENV['SOLUM_CLI']='~/dev/python-solumclient' path on local system to solum repo
# Set ENV['SOLUM_IMAGE_FORMAT'] to "vm" if you don't want docker
#############################################################################


host_cache_path = File.expand_path("../.cache", __FILE__)
guest_cache_path = "/tmp/vagrant-cache"

if ARGV.include? '--provider=rackspace'
  RACKSPACE = true
      unless ENV['PUBLIC_KEY']
        raise "Set ENV['PUBLIC_KEY'] to use rackspace provisioner"
      end
      unless ENV['PRIVATE_KEY']
        raise "Set ENV['PRIVATE_KEY'] to use rackspace provisioner"
      end
else
  RACKSPACE = false
end

if ARGV[0] == 'help' and ARGV[1] == 'vagrantfile'
  puts <<eof

How to use this Vagrantfile:

  * [SOLUM=~/dev/solum] vagrant up devstack [--provider==rackspace]

  see README.md for detailed instructions.

eof

  ARGV.shift(2)
  ARGV.unshift('status')
end

# ensure the cache path exists
FileUtils.mkdir(host_cache_path) unless File.exist?(host_cache_path)


############
# Variables and fun things to make my life easier.
############

# Uncomment me for WEBGUI magic
WEBGUI_BRANCH      = ENV['WEBGUI_BRANCH']      ||= "master"
WEBGUI_REPO        = ENV['WEBGUI_REPO']        ||= "https://github.com/rackerlabs/solum-m2demo-ui.git"
DEVSTACK_BRANCH    = ENV['DEVSTACK_BRANCH']    ||= "master"
DEVSTACK_REPO      = ENV['DEVSTACK_REPO']      ||= "https://github.com/openstack-dev/devstack.git"
NOVADOCKER_BRANCH  = ENV['NOVADOCKER_BRANCH']  ||= "master"
NOVADOCKER_REPO    = ENV['NOVADOCKER_REPO']    ||= "https://github.com/stackforge/nova-docker.git"
SOLUM_BRANCH       = ENV['SOLUM_BRANCH']       ||= "master"
SOLUM_CLI_BRANCH   = ENV['SOLUM_CLI_BRANCH']   ||= "master"
SOLUM_CLI_REPO     = ENV['SOLUM_CLI_REPO']     ||= "https://github.com/stackforge/python-solumclient.git"
SOLUM_IMAGE_FORMAT = ENV['SOLUM_IMAGE_FORMAT'] ||= "docker"
SOLUM_REPO         = ENV['SOLUM_REPO']         ||= "https://github.com/stackforge/solum.git"

############
# Chef provisioning stuff for non devstack boxes
############

# All servers get this
default_runlist = %w{ recipe[apt::default] recipe[solum::python] }
default_json = {

}

Vagrant.configure("2") do |config|

  # box configs!
  config.vm.box = 'ubuntu-12.04-docker'
  config.vm.box_url = 'https://oss-binaries.phusionpassenger.com/vagrant/boxes/2014-04-30/ubuntu-12.04-amd64-vbox.box'

  # all good servers deserve a solum
  if ENV['SOLUM']
    config.vm.synced_folder ENV['SOLUM'], "/opt/stack/solum"
  end

  if ENV['NOVADOCKER']
    config.vm.synced_folder ENV['NOVADOCKER'], '/opt/stack/nova-docker'
  end

# Uncomment me for WEBGUI magic
  if ENV['WEBGUI']
    config.vm.synced_folder ENV['WEBGUI'], '/opt/stack/solum-gui'
  end

  if ENV['SOLUM_CLI']
    config.vm.synced_folder ENV['SOLUM_CLI'], "/opt/stack/python-solumclient"
  end

  if RACKSPACE
    unless ENV['OS_USERNAME']
      puts "Set ENV['OS_USERNAME'] to use rackspace provisioner"
    end
    unless ENV['OS_PASSWORD']
      puts "Set ENV['OS_PASSWORD'] to use rackspace provisioner"
    end
    config.vm.provision :shell, :inline => <<-SCRIPT
      iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
      iptables -A INPUT -i eth0 -p tcp --dport ssh -j ACCEPT
      iptables -A INPUT -i eth0 -j DROP
      echo 'UseDNS no' >> /etc/ssh/sshd_config
      echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config
      service ssh reload
    SCRIPT
  end
  config.vm.provider :rackspace do |rs|
    rs.username    = ENV['OS_USERNAME']
    rs.api_key     = ENV['OS_PASSWORD']
    rs.flavor      = /2 GB Performance/
    rs.image       = /Ubuntu 12.04/
    rs.server_name = "#{ENV['USER']}_Vagrant"
    rs.public_key_path = ENV['PUBLIC_KEY']
  end
  if ENV['PRIVATE_KEY']
    config.ssh.private_key_path = ENV['PRIVATE_KEY']
  end

  # DevStack with Nova that may have Docker driver and/or Solum.
  config.vm.define :devstack do |devstack|
    devstack.vm.hostname = 'devstack'
    devstack.vm.network "forwarded_port", guest: 80,   host: 8080 # Horizon
    devstack.vm.network "forwarded_port", guest: 9001,   host: 9001 # Solum Demo GUI
    devstack.vm.network "forwarded_port", guest: 8774, host: 8774 # Compute API
    devstack.vm.network :private_network, ip: '192.168.76.11'

    devstack.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--memory", 4096]
      v.customize ["modifyvm", :id, "--cpus", 2]
      v.customize ["modifyvm", :id, "--nicpromisc1", "allow-all"]
    end
    devstack.vm.provider :rackspace do |rs|
      rs.server_name = "#{ENV['USER']}_#{devstack.vm.hostname}"
    end

    if ENV['TESTS']
      devstack.berkshelf.enabled = true
      devstack.omnibus.chef_version = :latest
      devstack.vm.provision :chef_solo do |chef|
        chef.provisioning_path  = guest_cache_path
        #chef.log_level          = :debug
        chef.json               = default_json.merge(api_json)
        chef.run_list           = default_runlist + api_runlist
      end
    else
      devstack.vm.provision :shell, :inline => <<-SCRIPT
        grep "vagrant" /etc/passwd  || useradd -m -s /bin/bash -d /home/vagrant vagrant
        grep "vagrant" /etc/sudoers || echo 'vagrant  ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
      SCRIPT

      devstack.vm.provision :shell, :inline => <<-SCRIPT
        apt-get update
        apt-get -y install git socat curl wget build-essential python-mysqldb \
            python-dev libssl-dev python-pip git-core libxml2-dev libxslt-dev \
            python-pip libmysqlclient-dev vim screen
        pip install virtualenv
        pip install tox==1.6.1
        mkdir -p /opt/stack
        chown vagrant /opt/stack
      SCRIPT
    end

    unless ENV['SOLUM']
      devstack.vm.provision :shell, :inline => <<-SCRIPT
        su vagrant -c "git clone #{SOLUM_REPO} /opt/stack/solum || echo /opt/stack/solum already exists"
        cd /opt/stack/solum
        su vagrant -c "git checkout #{SOLUM_BRANCH}"
      SCRIPT
    end

    # uncomment me for WEBGUI magic
    unless ENV['WEBGUI']
      devstack.vm.provision :shell, :inline => <<-SCRIPT
        su vagrant -c "git clone #{WEBGUI_REPO} /opt/stack/solum-gui || echo /opt/stack/solum-gui already exists"
        cd /opt/stack/solum-gui
        su vagrant -c "git checkout #{WEBGUI_BRANCH}"
      SCRIPT
    end

    devstack.vm.provision :shell, :inline => <<-SCRIPT
      su vagrant -c "git clone #{DEVSTACK_REPO} /home/vagrant/devstack || echo devstack already exists"
      cd /home/vagrant/devstack
      su vagrant -c "git checkout #{DEVSTACK_BRANCH}"
      su vagrant -c "touch localrc"
      cp -R /opt/stack/solum/contrib/devstack/lib/* /home/vagrant/devstack/lib/
      cp /opt/stack/solum/contrib/devstack/extras.d/* /home/vagrant/devstack/extras.d/
    SCRIPT

    if SOLUM_IMAGE_FORMAT == 'docker'
      devstack.vm.provision :shell, :inline => <<-SCRIPT
        echo 'Set up Nova Docker Driver'
        su vagrant -c "git clone #{NOVADOCKER_REPO} /opt/stack/nova-docker || echo novadocker already exists"
        cd /opt/stack/nova-docker
        su vagrant -c "git checkout #{NOVADOCKER_BRANCH}"
        cp -R /opt/stack/nova-docker/contrib/devstack/lib/* /home/vagrant/devstack/lib/
        cp /opt/stack/nova-docker/contrib/devstack/extras.d/* /home/vagrant/devstack/extras.d/
        # WORKAROUND after https://review.openstack.org/#/c/88382/
        sed -i 's/ln -snf/# ln -snf/' /home/vagrant/devstack/lib/nova_plugins/hypervisor-docker
        useradd docker || echo "user docker already exists"
        usermod -a -G docker vagrant || echo "vagrant already in docker group"
        cat /vagrant/localrc.docker > /home/vagrant/devstack/localrc
        su vagrant -c "/home/vagrant/devstack/stack.sh"
        # WORKAROUND after https://review.openstack.org/#/c/88382/
        cp /opt/stack/nova-docker/etc/nova/rootwrap.d/docker.filters  /etc/nova/rootwrap.d/docker.filters
        docker pull paulczar/slugrunner
        docker tag paulczar/slugrunner 127.0.0.1:5042/slugrunner
        docker push 127.0.0.1:5042/slugrunner
      SCRIPT
    else
      devstack.vm.provision :shell, :inline => <<-SCRIPT
        cat /vagrant/localrc.vm > /home/vagrant/devstack/localrc
        su vagrant -c "/home/vagrant/devstack/stack.sh"
      SCRIPT
    end

    devstack.vm.provision :shell, :inline => <<-SCRIPT
      cp /opt/stack/solum-gui/bridge/scripts/*.sh /home/vagrant
      su vagrant -c "/opt/stack/solum-gui/start-demo.sh"
    SCRIPT

  end

end
