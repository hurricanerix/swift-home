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
    - home: /home/swift
    - createhome: True

# Install dependencies
{% for a in ['gcc', 'memcached', 'rsync', 'sqlite3', 'xfsprogs',
             'libffi-dev', 'python-setuptools',
             'python-coverage', 'python-dev', 'python-nose',
             'python-simplejson', 'python-xattr', 'python-eventlet',
             'python-greenlet', 'python-pastedeploy',
             'python-netifaces', 'python-pip', 'python-dnspython',
             'python-mock'] %}
{{ a }}:
  pkg.installed
{% endfor %}

# Use partition for storage
sfdisk.layout:
  file.managed:
    - name: /opt/swift-home/sfdisk.layout
    - source: salt://saio/sfdisk.layout
    - user: swift
    - group: swift

# TODO: This is vagrant specific, prob a better way to handle it.
{% for d in ['sdb', 'sdc', 'sdd', 'sde'] %}
sudo sfdisk /dev/{{ d }} < /opt/swift-home/sfdisk.layout:
  cmd.run
{% endfor %}

# Get the code
/opt/swift-home/middleware:
  file.directory:
    - makedirs: True

https://github.com/openstack/swift.git:
  git.latest:
    - rev: master
    - target: /opt/swift-home/swift

https://github.com/openstack/python-swiftclient.git:
  git.latest:
    - rev: master
    - target: /opt/swift-home/python-swiftclient

https://github.com/gholt/swiftly.git:
  git.latest:
    - rev: master
    - target: /opt/swift-home/swiftly

https://github.com/zerovm/swift-browser.git:
  git.latest:
    - rev: master
    - target: /opt/swift-home/swift-browser

https://github.com/hurricanerix/swift-inspector.git:
  git.latest:
    - ref: master
    - target: /opt/swift-home/middleware/swift-inspector

https://github.com/hurricanerix/saio-fuse.git:
  git.latest:
    - rev: master
    - target: /opt/swift-home/saio-fuse

# Setup up rsync
## TODO: do this step

# Setup memcahced
## TODO: do this step

# Configure Swift
{% for f in ['account-server.conf', 'container-reconciler.conf',
             'container-server.conf', 'object-expirer.conf',
             'object-server.conf', 'proxy-server.conf',
             'swift.conf', 'test.conf'] %}
{{ f }}:
  file.managed:
    - name: /etc/swift/{{ f }}
    - source: salt://saio/etc/{{ f }}
    - user: root
    - group: swift
{% endfor %}

/etc/swift:
  file.directory:
    - makedirs: True
    - user: root
    - group: swift

# Set up scripts for running Swift
{% for f in ['remakerings','startmain','startrest'] %}
{{ f }}:
  file.managed:
    - name: /opt/swift-home/bin/{{ f }}
    - source: salt://saio/bin/{{ f }}
    - mode: 774
    - user: root
    - group: swift
{% endfor %}
