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
# Set ENV['DOCKER'] to enable the devstack docker driver
# Set ENV['SOLUM']='~/dev/solum' path on local system to solum repo
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

DEVSTACK_BRANCH = ENV['DEVSTACK_BRANCH'] || "master"

############
# Chef provisioning stuff for non devstack boxes
############

# All servers get this
default_runlist = %w{ recipe[apt::default] recipe[solum::python] recipe[solum::user] recipe[git] }
default_json = {
        authorization: {
          sudo: {
            users: ['vagrant'],
            passwordless: true,
            include_sudoers_d: true
          }
        }
}

# MySQL Server
mysql_runlist = %w{ recipe[mysql::server] recipe[solum::database] }
mysql_json = {
         mysql: {
          server_root_password:   "solum",
          server_debian_password: "solum",
          server_repl_password:   "solum"
        }
}

# RabbitMQ Server
rabbit_runlist = %w{ recipe[solum::rabbit] }
rabbit_json = {
        rabbitmq: {
          enabled_plugins: [ 'rabbitmq_management' ]
        }
}

# API Server
api_runlist = %w{ recipe[solum::api] }
api_json = {}

# Git Server
git_runlist = %w{ recipe[git::server] }
git_json = {}

Vagrant.configure("2") do |config|

  # all good servers deserve a solum
  if ENV['SOLUM']
    config.vm.synced_folder ENV['SOLUM'], "/solum"
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
    devstack.vm.network "forwarded_port", guest: 8774, host: 8774 # Compute API
    devstack.vm.network :private_network, ip: '192.168.76.11'

    devstack.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--memory", 2048]
      v.customize ["modifyvm", :id, "--cpus", 2]
      v.customize ["modifyvm", :id, "--nicpromisc1", "allow-all"]
    end
    devstack.vm.provider :rackspace do |rs|
      rs.server_name = "#{ENV['USER']}_#{devstack.vm.hostname}"
    end

    if ENV["DOCKER"]
      devstack.vm.box      = 'ubuntu1204-3.8'
      devstack.vm.box_url  = 'https://oss-binaries.phusionpassenger.com/vagrant/boxes/ubuntu-12.04.3-amd64-vbox.box'
    else
      devstack.vm.box      = 'opscode-ubuntu-12.04'
      devstack.vm.box_url  = 'https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box'
    end


    devstack.vm.provision :shell, :inline => <<-SCRIPT
      grep "vagrant" /etc/passwd  || useradd -m -s /bin/bash -d /home/vagrant vagrant
      grep "vagrant" /etc/sudoers || echo 'vagrant  ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
      apt-get update
      apt-get -y install git socat curl wget
    SCRIPT

    unless ENV['SOLUM']
      devstack.vm.provision "shell", inline: "git clone https://github.com/stackforge/solum.git /solum || echo /solum already exists."
    end

    devstack.vm.provision :shell, :inline => <<-SCRIPT
      su vagrant -c "git clone https://github.com/openstack-dev/devstack.git /home/vagrant/devstack || echo devstack already exists"
      cd /home/vagrant/devstack
      su vagrant -c "git checkout #{DEVSTACK_BRANCH}"
      su vagrant -c "touch localrc"
      echo DATABASE_PASSWORD=solum >> localrc
      echo RABBIT_PASSWORD=solum >> localrc
      echo SERVICE_TOKEN=solum >> localrc
      echo SERVICE_PASSWORD=solum >> localrc
      echo ADMIN_PASSWORD=solum >> localrc
      echo NOVNC_FROM_PACKAGE=false >> localrc
      echo 'ENABLED_SERVICES+=,heat,h-api,h-api-cfn,h-api-cw,h-eng' >> localrc
    SCRIPT
    if ENV["DOCKER"]
      devstack.vm.provision :shell, :inline => <<-SCRIPT
        useradd docker || echo "user docker already exists"
        usermod -a -G docker vagrant || echo "vagrant already in docker group"
        echo "DOCKER_REGISTRY_IMAGE=http://6bc6e9aa96b3ac52a4f4-abffaf981a2eb6b5e528f6c31e120f53.r19.cf2.rackcdn.com/docker-registry.tar.gz" >> /home/vagrant/devstack/localrc
        echo VIRT_DRIVER=docker >> /home/vagrant/devstack/localrc
        su vagrant -c "/home/vagrant/devstack/tools/docker/install_docker.sh"
      SCRIPT
    end

    devstack.vm.provision :shell, :inline => <<-SCRIPT
      mkdir -p /opt/stack
      chown vagrant /opt/stack
      [[ ! -L /opt/stack/solum ]] && su vagrant -c "ln -s /solum /opt/stack/solum"
      [[ ! -L /home/vagrant/devstack/lib/solum ]] && su vagrant -c "ln -s /solum/contrib/devstack/lib/solum /home/vagrant/devstack/lib/"
      [[ ! -L /home/vagrant/devstack/extras.d/solum ]] && su vagrant -c "ln -s /solum/extras.d/70-solum.sh /home/vagrant/devstack/extras.d/"
      echo "enable_service solum" >> /home/vagrant/devstack/localrc
      echo 'LOGFILE=/opt/stack/logs/stack.sh.log' >> /home/vagrant/devstack/localrc
      echo 'FLAT_INTERFACE=br100' >> /home/vagrant/devstack/localrc
      echo 'PUBLIC_INTERFACE=eth1' >> /home/vagrant/devstack/localrc
      echo 'FIXED_RANGE=192.168.78.0/24' >> /home/vagrant/devstack/localrc
      su vagrant -c "/home/vagrant/devstack/stack.sh"
      [[ -e /usr/local/bin/nova-manage ]] && for i in `seq 1 20`; do /usr/local/bin/nova-manage fixed reserve 192.168.78.$i; done
    SCRIPT

  end

  # The 'support' server - VM for mysql server and rabbitmq server
  config.vm.define :db do |db|
    db.vm.box      = 'opscode-ubuntu-12.04'
    db.vm.box_url  = 'https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box'
    db.vm.hostname = 'db'
    db.berkshelf.enabled = true
    db.omnibus.chef_version = :latest
    db.vm.network "forwarded_port", guest: 15672, host: 15672
    db.vm.network "forwarded_port", guest: 3306, host: 3306
    db.vm.network :private_network, ip: '192.168.76.12'
    db.vm.provision :chef_solo do |chef|
      chef.provisioning_path  = guest_cache_path
      #chef.log_level          = :debug
      chef.json               = default_json.merge(mysql_json).merge(rabbit_json)
      chef.run_list           = default_runlist + mysql_runlist + rabbit_runlist
    end
  end

  # The API server
  config.vm.define :api do |api|
    api.vm.box      = 'opscode-ubuntu-12.04'
    api.vm.box_url  = 'https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box'
    api.vm.hostname = 'api'
    api.berkshelf.enabled = true
    api.omnibus.chef_version = :latest
    api.vm.network :private_network, ip: '192.168.76.13'
    api.vm.provision :chef_solo do |chef|
      chef.provisioning_path  = guest_cache_path
      #chef.log_level          = :debug
      chef.json               = default_json.merge(api_json)
      chef.run_list           = default_runlist + api_runlist
    end
    if ENV['TESTS']
      api.vm.provision :shell, :inline => <<-SCRIPT
        cd /solum
        tox
      SCRIPT
    end
  end

  # The git server
  config.vm.define :git do |git|
    git.vm.box      = 'opscode-ubuntu-12.04'
    git.vm.box_url  = 'https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box'
    git.vm.hostname = 'git'
    git.berkshelf.enabled = true
    git.omnibus.chef_version = :latest
    git.vm.network :private_network, ip: '192.168.76.14'
    git.vm.provision :chef_solo do |chef|
      chef.provisioning_path  = guest_cache_path
      #chef.log_level          = :debug
      chef.json               = default_json.merge(git_json)
      chef.run_list           = default_runlist + git_runlist
    end
  end

  # This VM contains - git server, api server, mysql server, rabbitmq server
  config.vm.define :allinone do |allinone|
    allinone.vm.box      = 'opscode-ubuntu-12.04'
    allinone.vm.box_url  = 'https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box'
    allinone.vm.hostname = 'allinone'
    allinone.vm.provider :rackspace do |rs|
      rs.flavor      = /1 GB Performance/
      rs.server_name = "#{ENV['USER']}_allinone"
    end
    allinone.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--memory", 2048]
      v.customize ["modifyvm", :id, "--cpus", "2"]
    end
    allinone.berkshelf.enabled = true
    allinone.omnibus.chef_version = :latest
    allinone.vm.network "forwarded_port", guest: 15672, host: 15672
    allinone.vm.network "forwarded_port", guest: 3306, host: 3306
    allinone.vm.network :private_network, ip: '192.168.76.10'
    allinone.vm.provision :chef_solo do |chef|
      chef.provisioning_path = guest_cache_path
      chef.log_level         = :debug
      chef.json               = default_json.merge(mysql_json).merge(rabbit_json).merge(git_json).merge(api_json)
      chef.run_list           = default_runlist + mysql_runlist + rabbit_runlist + git_runlist + api_runlist
    end
    unless ENV['SOLUM']
      allinone.vm.provision "shell", inline: "git clone https://github.com/stackforge/solum.git /solum || echo /solum already exists."
    end
  end

end