# -*- mode: ruby -*-
# vi: set ft=ruby :

# Copyright 2015 Richard Hawkins
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

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.network :forwarded_port, guest: 8080, host: 8080

  config.vm.synced_folder "salt/roots", "/srv/salt/", :owner=> 'vagrant', :group=>'vagrant', :mount_options => ['dmode=775', 'fmode=775']
  # config.vm.synced_folder "salt/pillar", "/srv/pillar/", :owner=> 'vagrant', :group=>'vagrant', :mount_options => ['dmode=775', 'fmode=775']

  config.vm.provider "virtualbox" do |vb|
    vb.name = "swift-home"
  end

  config.vm.provision :salt do |salt|
    salt.minion_config = "salt/minion"
    salt.run_highstate = true
  end
end
