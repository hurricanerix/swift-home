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
    - password: $1$8Oyu9skc$DLcrnfjHKeBBtx5ZOtPdu0
    - groups:
        - sudo

/opt/swift-home/swift/bin:
  file.directory:
    - makedirs: True
    - user: swift
    - group: swift

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
{% for mp in ['disk1', 'disk2', 'disk3', 'disk4'] %}
/srv/{{ mp }}:
  file.directory:
    - makedirs: True
    - user: swift
    - group: swift
{% endfor %}

/etc/fstab:
  file.append:
    - text:
      - LABEL=SWIFT_DISK1 /srv/disk1 xfs user,noatime,nodiratime,nobarrier,logbufs=8 0 0
      - LABEL=SWIFT_DISK2 /srv/disk2 xfs user,noatime,nodiratime,nobarrier,logbufs=8 0 0
      - LABEL=SWIFT_DISK3 /srv/disk3 xfs user,noatime,nodiratime,nobarrier,logbufs=8 0 0
      - LABEL=SWIFT_DISK4 /srv/disk4 xfs user,noatime,nodiratime,nobarrier,logbufs=8 0 0

swift_setup_disks:
  file.managed:
    - name: /opt/swift-home/swift/bin/setup_disks
    - source: salt://swift/bin/setup_disks
    - user: swift
    - group: swift
    - mode: 744

{% for device in ['/dev/sdb', '/dev/sdc', '/dev/sdd', '/dev/sde'] %}
/opt/swift-home/swift/bin/setup_disks {{ device }}:
  cmd.run
{% endfor %}
