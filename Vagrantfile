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
# Set ENV['SOLUMCLIENT']='~/dev/python-solumclient' path on local system to solum repo
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

if ARGV.include? '--provider=openstack'
  require 'vagrant-openstack-provider'
  OPENSTACK = true
  unless ENV['PRIVATE_KEY']
    raise "Set ENV['PRIVATE_KEY'] to use openstack provider"
  end
  unless ENV['OS_USERNAME']
    puts "Set ENV['OS_USERNAME'] to use openstack provider"
  end
  unless ENV['OS_PASSWORD']
    puts "Set ENV['OS_PASSWORD'] to use openstack provider"
  end
  unless ENV['OS_AUTH_URL']
    puts "Set ENV['OS_AUTH_URL'] to use openstack provider"
  end
  unless ENV['OS_TENANT_NAME']
    puts "Set ENV['OS_TENANT_NAME'] to use openstack provider"
  end
  unless ENV['OS_FLOATING_IP']
    puts "Set ENV['OS_FLOATING_IP'] to use openstack provider"
  end
  unless ENV['OS_FLAVOR']
    puts "Set ENV['OS_FLAVOR'] to use openstack provider"
  end
  unless ENV['OS_IMAGE']
    puts "Set ENV['OS_IMAGE'] to use openstack provider"
  end
  unless ENV['OS_KEYPAIR_NAME']
    puts "Set ENV['OS_KEYPAIR_NAME'] to use openstack provider"
  end
  unless ENV['OS_SSH_USERNAME']
    puts "Set ENV['OS_SSH_USERNAME'] to use openstack provider"
  end
else
  OPENSTACK = false
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

DEVSTACK_BRANCH       = ENV['DEVSTACK_BRANCH']       ||= "master"
DEVSTACK_REPO         = ENV['DEVSTACK_REPO']         ||= "https://github.com/openstack-dev/devstack.git"
NOVADOCKER_BRANCH     = ENV['NOVADOCKER_BRANCH']     ||= "7e55fd551ef4faf3499a8db056efc9535c20e434"
NOVADOCKER_REPO       = ENV['NOVADOCKER_REPO']       ||= "https://github.com/openstack/nova-docker.git"
NEUTRON_BRANCH        = ENV['NEUTRON_BRANCH']        ||= "775893bb7f61c4641acbcb4ae16edf16e0989c39"
NEUTRON_REPO          = ENV['NEUTRON_REPO']          ||= "https://github.com/openstack/neutron.git"
NOVA_BRANCH           = ENV['NOVA_BRANCH']           ||= "859ff4893f699b680fec4db7dedd3bec8c8d0a1c"
NOVA_REPO             = ENV['NOVA_REPO']             ||= "https://github.com/openstack/nova.git"
SOLUM_BRANCH          = ENV['SOLUM_BRANCH']          ||= "master"
SOLUM_REPO            = ENV['SOLUM_REPO']            ||= "https://github.com/openstack/solum.git"
SOLUMCLIENT_BRANCH    = ENV['SOLUMCLIENT_BRANCH']    ||= "master"
SOLUMCLIENT_REPO      = ENV['SOLUMCLIENT_REPO']      ||= "https://github.com/openstack/python-solumclient.git"
SOLUM_IMAGE_FORMAT    = ENV['SOLUM_IMAGE_FORMAT']    ||= "docker"
WEBGUI_BRANCH         = ENV['WEBGUI_BRANCH']         ||= "master"
WEBGUI_REPO           = ENV['WEBGUI_REPO']           ||= "https://github.com/rackerlabs/solum-m2demo-ui.git"

############
# Chef provisioning stuff for non devstack boxes
############

# All servers get this
default_runlist = %w{ recipe[apt::default] recipe[solum::python] }
default_json = {

}

Vagrant.configure("2") do |config|

  # box configs!
  config.vm.box = 'ubuntu/trusty64'

  # all good servers deserve a solum
  if ENV['SOLUM']
    config.vm.synced_folder ENV['SOLUM'], "/opt/stack/solum"
  end

  if ENV['SOLUM_PARENT']
    config.vm.synced_folder ENV['SOLUM'], "/opt/stack/solum_parent"
  end

  #if ENV['NOVADOCKER']
  #  config.vm.synced_folder ENV['NOVADOCKER'], '/opt/stack/nova-docker'
  #end

  if ENV['SWIFT']
    config.vm.synced_folder ENV['SWIFT'], "/opt/stack/swift"
  end

  if ENV['WEBGUI']
    config.vm.synced_folder ENV['WEBGUI'], "/opt/stack/solum-gui"
  end

  if ENV['SOLUMCLIENT']
    config.vm.synced_folder ENV['SOLUMCLIENT'], "/opt/stack/python-solumclient"
  end

  if ENV['NOVA']
    config.vm.synced_folder ENV['NOVA'], "/opt/stack/nova"
  end

  if ENV['HEAT']
    config.vm.synced_folder ENV['HEAT'], "/opt/stack/heat"
  end

  if ENV['HEATCLIENT']
    config.vm.synced_folder ENV['HEATCLIENT'], "/opt/stack/python-heatclient"
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
    rs.flavor      = /4 GB Performance/
    rs.image       = /Ubuntu 14.04/
    rs.server_name = "#{ENV['USER']}_Vagrant"
    rs.public_key_path = ENV['PUBLIC_KEY']
  end
  if ENV['PRIVATE_KEY']
    config.ssh.private_key_path = ENV['PRIVATE_KEY']
  end

  if OPENSTACK
    config.vm.provision :shell, :inline => <<-SCRIPT
      iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
      iptables -A INPUT -i eth0 -p tcp --dport ssh -j ACCEPT
      iptables -A INPUT -i eth0 -j DROP
      echo 'UseDNS no' >> /etc/ssh/sshd_config
      echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config
      service ssh reload
    SCRIPT
  end
  config.vm.provider :openstack do |os, override|
    os.server_name = "#{ENV['USER']}_Vagrant"
    os.username = ENV['OS_USERNAME']
    os.password = ENV['OS_PASSWORD']
    os.openstack_auth_url = ENV['OS_AUTH_URL']
    os.tenant_name = ENV['OS_TENANT_NAME']
    os.floating_ip = ENV['OS_FLOATING_IP']
    os.flavor = ENV['OS_FLAVOR']
    os.image = ENV['OS_IMAGE']
    os.keypair_name = ENV['OS_KEYPAIR_NAME']
    os.ssh_username = ENV['OS_SSH_USERNAME']
  end

  # DevStack with Nova that may have Docker driver and/or Solum.
  config.vm.define :devstack do |devstack|
    devstack.vm.hostname = 'devstack'
    devstack.vm.network "forwarded_port", guest: 80,   host: 8080 # Horizon
    devstack.vm.network "forwarded_port", guest: 9001,   host: 9001 # Solum Demo GUI
    devstack.vm.network "forwarded_port", guest: 8774, host: 8774 # Compute API
    devstack.vm.network "forwarded_port", guest: 9777, host: 9777 # Solum API
    devstack.vm.network :private_network, ip: '192.168.76.2'
    devstack.vm.network :private_network, ip: '172.24.4.225', :netmask => "255.255.255.224", :auto_config => false

    devstack.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--memory", 10000]
      v.customize ["modifyvm", :id, "--cpus", 2]
      v.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
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

        # liberasurecode-dev is available in trusty-backports
        echo "Uncommenting trust-backports from /etc/apt/sources.list"
        sudo chmod 777 /etc/apt/sources.list
        sudo echo "deb http://archive.ubuntu.com/ubuntu trusty-backports main restricted universe multiverse" >> /etc/apt/sources.list
        sudo echo "deb-src http://archive.ubuntu.com/ubuntu trusty-backports main restricted universe multiverse" >> /etc/apt/sources.list
        sudo chmod 644 /etc/apt/sources.list

        sudo apt-get update
        sudo apt-get -y install git socat curl wget build-essential python-mysqldb \
            python-dev libssl-dev python-pip git-core libxml2-dev libxslt-dev \
            python-pip libmysqlclient-dev vim screen emacs libldap2-dev \
            libsasl2-dev linux-image-extra-$(uname -r) liberasurecode-dev
        sudo pip install virtualenv
        sudo pip install tox==2.3.1
        sudo pip install setuptools
        sudo pip install python-ldap
        sudo mkdir -p /opt/stack
        sudo chown vagrant /opt/stack
        sudo mkdir -p /var/log/solum/worker
        sudo chown vagrant /var/log/solum/worker
        sudo mkdir -p /var/log/solum/deployer
        sudo chown vagrant /var/log/solum/deployer
      SCRIPT
    end

    unless ENV['SOLUM']
      devstack.vm.provision :shell, :inline => <<-SCRIPT
        echo su - vagrant -c "git clone #{SOLUM_REPO} /opt/stack/solum || echo /opt/stack/solum already exists"
        su - vagrant -c "git clone #{SOLUM_REPO} /opt/stack/solum || echo /opt/stack/solum already exists"
        cd /opt/stack/solum
        su vagrant -c "git checkout #{SOLUM_BRANCH}"

      SCRIPT
    end

    unless ENV['WEBGUI']
      devstack.vm.provision :shell, :inline => <<-SCRIPT
        su - vagrant -c "git clone #{WEBGUI_REPO} /opt/stack/solum-gui || echo /opt/stack/solum-gui already exists"
        cd /opt/stack/solum-gui
        su vagrant -c "git checkout #{WEBGUI_BRANCH}"
      SCRIPT
    end

    devstack.vm.provision :shell, :inline => <<-SCRIPT
      su - vagrant -c "git clone #{DEVSTACK_REPO} /home/vagrant/devstack || echo devstack already exists"
      cd /home/vagrant/devstack
      su vagrant -c "git checkout #{DEVSTACK_BRANCH}"
      su vagrant -c "touch local.conf"
      cp -R /opt/stack/solum/contrib/add-ons/lib/* /home/vagrant/devstack/lib/
      cp /opt/stack/solum/contrib/add-ons/extras.d/* /home/vagrant/devstack/extras.d/
    SCRIPT

    if SOLUM_IMAGE_FORMAT == 'docker'
      devstack.vm.provision :shell, :inline => <<-SCRIPT
        #echo 'Set up Nova Docker Driver'
        #if [[ ! -d /opt/stack/nova-docker ]]; then
        #  su - vagrant -c "git clone #{NOVADOCKER_REPO} /opt/stack/nova-docker"
        #  cd /opt/stack/nova-docker
        #  su vagrant -c "git checkout #{NOVADOCKER_BRANCH}"
        #fi
        #useradd docker || echo "user docker already exists"
        #usermod -a -G docker vagrant || echo "vagrant already in docker group"
        cat /vagrant/local.conf.docker > /home/vagrant/devstack/local.conf

        echo 'Get Nova'
        if [[ ! -d /opt/stack/nova ]]; then
          su - vagrant -c "git clone #{NOVA_REPO} /opt/stack/nova"
          cd /opt/stack/nova
          su vagrant -c "git checkout #{NOVA_BRANCH}"
        fi

        echo 'Get Neutron'
        if [[ ! -d /opt/stack/neutron ]]; then
          su - vagrant -c "git clone #{NEUTRON_REPO} /opt/stack/neutron"
          cd /opt/stack/neutron
          su vagrant -c "git checkout #{NEUTRON_BRANCH}"
        fi

        # Set env variable required by tempest
        export OS_TEST_TIMEOUT=1200

        pushd /home/vagrant/devstack
        export REQUIREMENTS_MODE=soft
        su vagrant -c "/home/vagrant/devstack/stack.sh"
        popd

        . /home/vagrant/devstack/openrc admin

      SCRIPT
    else
      devstack.vm.provision :shell, :inline => <<-SCRIPT
        cat /vagrant/local.conf.vm > /home/vagrant/devstack/local.conf
        pushd /home/vagrant/devstack
        su vagrant -c "/home/vagrant/devstack/stack.sh"
        popd
      SCRIPT
    end

    if ENV['USE_SOLUM_UI']
      devstack.vm.provision :shell, :inline => <<-SCRIPT
        cp /opt/stack/solum-gui/bridge/scripts/*.sh /home/vagrant
        su vagrant -c "/opt/stack/solum-gui/start-demo.sh"
      SCRIPT
    end

  end

end