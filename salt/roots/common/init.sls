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

{% for pkg in ['curl','git', 'zsh'] %}
{{ pkg }}:
  pkg.installed
{% endfor %}

/opt/swift-home/bin:
  file.directory:
    - makedirs: True

# Setup Firewall
firewall:
  file.managed:
    - name: /opt/swift-home/bin/firewall
    - source: salt://common/bin/firewall
    - mode: 744

/etc/network/interfaces:
  file.managed:
    - name: /etc/network/interfaces
    - source: salt://common/etc/network-interfaces

/etc/init.d/networking restart:
  cmd.run

# Setup oh-my-zsh
https://github.com/robbyrussell/oh-my-zsh.git:
  git.latest:
    - target: /opt/swift-home/oh-my-zsh
