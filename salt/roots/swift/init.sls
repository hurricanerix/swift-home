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
    - home: /opt/swift-home/home
    - createhome: True

zshrc:
  file.managed:
    - name: /opt/swift-home/home/.zshrc
    - source: salt://swift/home/zshrc

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
