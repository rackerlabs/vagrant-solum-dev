# Solum Dev Environment with Vagrant

## About

The purpose of this Repo is to help you quickly set up a consistent development environment
for working on Solum. It will deploy devstack and the solum repo and get everything started.

It is designed to be run with Vagrant/VirtualBox on your local desktop, but there is some experimental
support for using the Rackspace Cloud Provider.

## Prerequsites

* Vagrant 1.3.x  ( http://downloads.vagrantup.com/tags/v1.3.5 )
* Virtualbox ( https://www.virtualbox.org/wiki/Downloads )

__Vagrant Plugins ( in this order! )__

```
vagrant plugin install vagrant-omnibus
vagrant plugin install vagrant-berkshelf
```

* a clone of this repo

```
git clone https://github.com/rackerlabs/vagrant-solum-dev.git
cd vagrant-solum-dev
```

### Experimental Rackspace Cloud Support

__Vagrant Rackspace Provider__

* set environment variables
*  * `OS_USERNAME` `OS_PASSWORD` `PUBLIC_KEY` `PRIVATE_KEY`
* will use DFW performance 2gb servers.
* will firewall everything but port 22 ( ssh )

```
vagrant plugin install vagrant-rackspace
```

## Using

Default boxes are `Ubuntu 12.04` supplied.  To use Fedora19 set the 
environment variable `FEDORA=true`.

### Devstack

#### Launching

__Devstack + Solum__

`vagrant up devstack`

__Devstack + Solum (mapped from local path)__

`SOLUM=~/dev/solum vagrant up devstack`

__Devstack + Solum + Tox pre-reqs__

`TESTS=1 SOLUM=../code vagrant up devstack`

__Devstack + Solum + Docker__

`DOCKER=true vagrant up devstack`

__Devstack + Solum to Rackspace Cloud__

_experimental_

```
export OS_USERNAME=username
export OS_PASSWORD=api-key
export PUBLIC_KEY=/path/to/public.key
export PRIVATE_KEY=/path/to/private.key
vagrant up devstack --provider=rackspace
```

__Run Tox Unit Tests__

`TESTS=true SOLUM=~/dev/solum vagrant up api`

* the first run will be slow,  but subsequent runs should be quite fast.
* /solum on the guest vm will be mapped from the path specified by SOLUM from the host.
* can be rerun on an already running VM by doing : `TESTS=true vagrant provision api`

#### Using

```
vagrant ssh devstack
source /vagrant/openrc
nova list
```

#### Things worth knowing

* all default passwords etc are set to 'solum' for simplicity.
* some of the shell provisioning may not be idempotent,  so be careful running subsequent `vagrant provision`

### Support servers

In case you want to be able to run your own mysql/rabbit/python boxes rather than use
the built in devstack ones.  I have also included definitions to start up VMs for them.


#### All In One

```
vagrant up allinone
```

#### Seperate VMs

```
vagrant up db
vagrant up api
vagrant up git
```

#### Thigs worth knowing

* uses Berkshelf + Chef-solo to install apps and set users etc.   Wrapper recipes found in `recipes/`.

* from your local machine you can ssh into any of the VMs in the environment simply by running `vagrant ssh <hostname>`,  the vagrant user has passwordless sudo access.

* each service has a path in the local repo mapped to it.    `sql`, `web`, `git`.   These will get mapped to the `/vagrant` directory on each VM ... so `sql` becomes `/vagrant/sql`.   This allows you to work off the same set of files in both the local and the VMs.    the local solum dir is also mapped to /solum on the VMs.

* the user 'solum' is created on each VM, and a mysql database + user/pass is also created.   The values of theses are set in the `attributes/default.rb` file, and can be overrided in the the various JSON blobs in the Vagrantfile.

##### Rabbit MQ

http://127.0.0.1:15672 to access theRabbitMQ Control panel.

Default user/pass combo is solum/solum ( guest/guest also works )  and there are two default vhosts /solum1, /solum2.

There is no persistence or HA.

##### GIT

Git server/client is installed.   no setup beyond that.

##### MySQL

mysql username: root,  password:  solum.

Once we start building actual databases we should create a solum user and database as part of the install ( chef! ) and not use the root user.

##### API

Initially was Python+falcon,  but sounds like we'll be changing away from that.


## Testing ( The chef recipes )
    rvm 1.9.3       # if using rvm
    bundle install
    bundle exec berks install
    bundle exec strainer test

License and Author
==================

|                      |                                                    |
|:---------------------|:---------------------------------------------------|
| **Author**           | Paul Czarkowski (pczarkowski@rackspace.com)        |
|                      |                                                    |
| **Copyright**        | Copyright (c) 2013, Rackspace                      |


Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
