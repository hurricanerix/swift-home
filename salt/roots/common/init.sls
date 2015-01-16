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

{% for a in ['curl','git'] %}
{{ a }}:
  pkg.installed
{% endfor %}

zsh:
    pkg.installed

/opt/swift-home/bin:
  file.directory:
    - makedirs: True

{% for f in ['firewall'] %}
{{ f }}:
  file.managed:
    - name: /opt/swift-home/bin/{{ f }}
    - source: salt://common/bin/{{ f }}
    - mode: 744
{% endfor %}

/etc/network/interfaces:
  file.managed:
    - name: /etc/network/interfaces
    - source: salt://common/etc/network-interfaces

# TODO: Firewal does not start without a reboot
