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
NOVADOCKER_BRANCH     = ENV['NOVADOCKER_BRANCH']     ||= "master"
NOVADOCKER_REPO       = ENV['NOVADOCKER_REPO']       ||= "https://github.com/stackforge/nova-docker.git"
SOLUM_BRANCH          = ENV['SOLUM_BRANCH']          ||= "master"
SOLUM_REPO            = ENV['SOLUM_REPO']            ||= "https://github.com/stackforge/solum.git"
SOLUMCLIENT_BRANCH    = ENV['SOLUMCLIENT_BRANCH']    ||= "master"
SOLUMCLIENT_REPO      = ENV['SOLUMCLIENT_REPO']      ||= "https://github.com/stackforge/python-solumclient.git"
SOLUM_IMAGE_FORMAT    = ENV['SOLUM_IMAGE_FORMAT']    ||= "docker"
MISTRAL_BRANCH        = ENV['MISTRAL_BRANCH']        ||= "master"
MISTRAL_REPO          = ENV['MISTRAL_REPO']          ||= "https://github.com/stackforge/mistral.git"
MISTRALCLIENT_BRANCH  = ENV['MISTRALCLIENT_BRANCH']  ||= "master"
MISTRALCLIENT_REPO    = ENV['MISTRALCLIENT_REPO']    ||= "https://github.com/stackforge/python-mistralclient.git"
BARBICAN_BRANCH       = ENV['BARBICAN_BRANCH']       ||= "master"
BARBICAN_REPO         = ENV['BARBICAN_REPO']         ||= "https://github.com/openstack/barbican.git"
BARBICANCLIENT_BRANCH = ENV['BARBICANCLIENT_BRANCH'] ||= "master"
BARBICANCLIENT_REPO   = ENV['BARBICANCLIENT_REPO']   ||= "https://github.com/openstack/python-barbicanclient.git"
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

  if ENV['NOVADOCKER']
    config.vm.synced_folder ENV['NOVADOCKER'], '/opt/stack/nova-docker'
  end

  if ENV['SWIFT']
    config.vm.synced_folder ENV['SWIFT'], "/opt/stack/swift"
  end

  if ENV['WEBGUI']
    config.vm.synced_folder ENV['WEBGUI'], "/opt/stack/solum-gui"
  end

  if ENV['SOLUMCLIENT']
    config.vm.synced_folder ENV['SOLUMCLIENT'], "/opt/stack/python-solumclient"
  end

  if ENV['MISTRAL']
    config.vm.synced_folder ENV['MISTRAL'], "/opt/stack/mistral"
  end

  if ENV['MISTRALCLIENT']
    config.vm.synced_folder ENV['MISTRALCLIENT'], "/opt/stack/python-mistralclient"
  end

  if ENV['BARBICAN']
    config.vm.synced_folder ENV['BARBICAN'], "/opt/stack/barbican"
  end

  if ENV['BARBICANCLIENT']
    config.vm.synced_folder ENV['BARBICANCLIENT'], "/opt/stack/python-barbicanclient"
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
      v.customize ["modifyvm", :id, "--memory", 6144]
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
        apt-get update
        apt-get -y install git socat curl wget build-essential python-mysqldb \
            python-dev libssl-dev python-pip git-core libxml2-dev libxslt-dev \
            python-pip libmysqlclient-dev vim screen
        pip install virtualenv
        pip install tox==1.6.1
        pip install setuptools
        mkdir -p /opt/stack
        chown vagrant /opt/stack
        mkdir -p /var/log/solum/worker
        chown vagrant /var/log/solum/worker
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

    unless ENV['MISTRAL']
      devstack.vm.provision :shell, :inline => <<-SCRIPT
        echo su - vagrant -c "git clone #{MISTRAL_REPO} /opt/stack/mistral || echo /opt/stack/mistral already exists"
        su - vagrant -c "git clone #{MISTRAL_REPO} /opt/stack/mistral || echo /opt/stack/mistral already exists"
        cd /opt/stack/mistral
        su vagrant -c "git checkout #{MISTRAL_BRANCH}"
      SCRIPT
    end

    unless ENV['MISTRALCLIENT']
      devstack.vm.provision :shell, :inline => <<-SCRIPT
        echo su - vagrant -c "git clone #{MISTRALCLIENT_REPO} /opt/stack/python-mistralclient || echo /opt/stack/python-mistralclient already exists"
        su - vagrant -c "git clone #{MISTRALCLIENT_REPO} /opt/stack/python-mistralclient || echo /opt/stack/python-mistralclient already exists"
        cd /opt/stack/python-mistralclient
        su vagrant -c "git checkout #{MISTRALCLIENT_BRANCH}"
      SCRIPT
    end

    unless ENV['BARBICAN']
      devstack.vm.provision :shell, :inline => <<-SCRIPT
        echo su - vagrant -c "git clone #{BARBICAN_REPO} /opt/stack/barbican || echo /opt/stack/barbican already exists"
        su - vagrant -c "git clone #{BARBICAN_REPO} /opt/stack/barbican || echo /opt/stack/barbican already exists"
        cd /opt/stack/barbican
        su vagrant -c "git checkout #{BARBICAN_BRANCH}"
      SCRIPT
    end

    unless ENV['BARBICANCLIENT']
      devstack.vm.provision :shell, :inline => <<-SCRIPT
        echo su - vagrant -c "git clone #{BARBICANCLIENT_REPO} /opt/stack/python-barbicanclient || echo /opt/stack/python-barbicanclient already exists"
        su - vagrant -c "git clone #{BARBICANCLIENT_REPO} /opt/stack/python-barbicanclient || echo /opt/stack/python-barbicanclient already exists"
        cd /opt/stack/python-barbicanclient
        su vagrant -c "git checkout #{BARBICANCLIENT_BRANCH}"
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
      cp -R /opt/stack/solum/contrib/devstack/lib/* /home/vagrant/devstack/lib/
      cp /opt/stack/solum/contrib/devstack/extras.d/* /home/vagrant/devstack/extras.d/
    SCRIPT

    devstack.vm.provision :shell, :inline => <<-SCRIPT
      cp -R /opt/stack/mistral/contrib/devstack/lib/* /home/vagrant/devstack/lib/
      cp /opt/stack/mistral/contrib/devstack/extras.d/* /home/vagrant/devstack/extras.d/
      cd /opt/stack/python-mistralclient
      python setup.py install

      cp -R /opt/stack/barbican/contrib/devstack/lib/* /home/vagrant/devstack/lib/
      cp /opt/stack/barbican/contrib/devstack/extras.d/* /home/vagrant/devstack/extras.d/
      cd /opt/stack/python-barbicanclient
      python setup.py install
    SCRIPT

    if SOLUM_IMAGE_FORMAT == 'docker'
      devstack.vm.provision :shell, :inline => <<-SCRIPT
        echo 'Set up Nova Docker Driver'
        if [[ ! -d /opt/stack/nova-docker ]]; then
          su - vagrant -c "git clone #{NOVADOCKER_REPO} /opt/stack/nova-docker"
          cd /opt/stack/nova-docker
          su vagrant -c "git checkout #{NOVADOCKER_BRANCH}"
        fi
        cp -R /opt/stack/nova-docker/contrib/devstack/lib/* /home/vagrant/devstack/lib/
        cp /opt/stack/nova-docker/contrib/devstack/extras.d/* /home/vagrant/devstack/extras.d/
        useradd docker || echo "user docker already exists"
        usermod -a -G docker vagrant || echo "vagrant already in docker group"
        cat /vagrant/local.conf.docker > /home/vagrant/devstack/local.conf
        pushd /home/vagrant/devstack
        su vagrant -c "/home/vagrant/devstack/stack.sh"
        su vagrant -c "screen -r stack -X hardstatus alwayslastline '%{= .} %-Lw%{= .}%> %n%f %t*%{= .}%+Lw%< %-=%{g}(%{d}%H/%l%{g})'"
        popd
        # just in case the rootwrap.d didn't make it.
        [[ -e /etc/nova/rootwrap.d/docker.filters ]] || cp /opt/stack/nova-docker/etc/nova/rootwrap.d/docker.filters  /etc/nova/rootwrap.d/docker.filters

        . /home/vagrant/devstack/openrc admin
        glance image-list
        if [[ $? == 0 ]]; then
            docker pull solum/slugbuilder:latest
            docker save solum/slugbuilder | glance image-create --is-public=True --container-format=docker --disk-format=raw --name "solum/slugbuilder"
            docker pull solum/slugrunner:latest
            docker save solum/slugrunner | glance image-create --is-public=True --container-format=docker --disk-format=raw --name "solum/slugrunner"
            docker pull solum/slugtester:latest
            docker save solum/slugtester | glance image-create --is-public=True --container-format=docker --disk-format=raw --name "solum/slugtester"
        else
            echo There was a problem talking to Glance. You will need to pull and save solum/slugbuilder, solum/slugrunner, and solum/slugtester manually.
        fi
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
