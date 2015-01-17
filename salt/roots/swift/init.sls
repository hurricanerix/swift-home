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

# Create User
swift:
  user.present:
    - fullname: Swift User
    - shell: /usr/bin/zsh
    - home: /opt/swift-home/swift
    - createhome: True

swift-zshrc:
  file.managed:
    - name: /opt/swift-home/swift/.zshrc
    - source: salt://swift/zshrc
    - user: swift
    - group: swift

sfdisk.layout:
  file.managed:
    - name: /opt/swift-home/swift/sfdisk.layout
    - source: salt://swift/sfdisk.layout
    - user: swift
    - group: swift

# Install dependencies
{% for pkg in ['gcc', 'memcached', 'rsync', 'sqlite3', 'xfsprogs',
             'libffi-dev', 'python-setuptools',
             'python-coverage', 'python-dev', 'python-nose',
             'python-simplejson', 'python-xattr', 'python-eventlet',
             'python-greenlet', 'python-pastedeploy',
             'python-netifaces', 'python-pip', 'python-dnspython',
             'python-mock'] %}
{{ pkg }}:
  pkg.installed
{% endfor %}

# Use a partition for storage
{% for device in ['sdb', 'sdc', 'sdd', 'sde'] %}
sudo sfdisk /dev/{{ device }} < /opt/swift-home/swift/sfdisk.layout:
  cmd.run

sudo mkfs.xfs -f /dev/{{ device }}1:
  cmd.run

/srv/{{ device }}1:
  file.directory:
    - makedirs: True
    - user: swift
    - group: swift
{% endfor %}

/etc/fstab:
  file.append:
    - text:
      - "/dev/sdb1 /srv/sdb1 xfs user,noatime,nodiratime,nobarrier,logbufs=8 0 0"
      - "/dev/sdc1 /srv/sdc1 xfs user,noatime,nodiratime,nobarrier,logbufs=8 0 0"
      - "/dev/sdd1 /srv/sdd1 xfs user,noatime,nodiratime,nobarrier,logbufs=8 0 0"
      - "/dev/sde1 /srv/sde1 xfs user,noatime,nodiratime,nobarrier,logbufs=8 0 0"
