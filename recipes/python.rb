#
# Cookbook Name:: python
# Recipe:: api
#
# Copyright 2012, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if node['platform'] == 'ubuntu'

  include_recipe 'python'

  apt_repository 'deadsnakes' do
    uri           'http://ppa.launchpad.net/fkrull/deadsnakes/ubuntu/'
    keyserver     'keyserver.ubuntu.com'
    key           'DB82666C'
    components    ['main']
    distribution  node['lsb']['codename']
    action        [:add]
  end

  ['python-gdbm', 'python2.6', 'python2.7', 'python3.3', 'pypy-dev'].each do |pkg|
    package pkg do
      action      :install
    end
  end


  %w{ libxml2-dev  libxslt-dev }.each do |pkg|
    package pkg do
      action :install
    end
  end

  python_pip 'virtualenv'

  python_pip 'tox' do
    package_name  'tox'
    action        [:install]
    version       '1.6.1'
  end

else node['platform'] == 'fedora'

  ['gdbm-devel', 'python-devel', 'python3-devel', 'pypy-devel'].each do |pkg|
    package pkg do
      action      :install
    end
  end

end
