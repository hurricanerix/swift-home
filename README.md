Swift@Home
==========

A custom [OpenStack Swift](https://github.com/openstack/swift)
[All-In-One](http://docs.openstack.org/developer/swift/development_saio.html)
for object storage at home.

<strong>Note:</strong>  This project is currently in the development phase and
should be considered non-working/unstable until this note is removed.

The goal of this project is to have Swift running at home for object storage.  In addition to the following goals:

1. It should be easy to stream media stored in a container to media plaers.

    a. The current plan is to have [Plex Media Server](https://plex.tv/) installed, and add
containers storing media using [SAIO-Fuse](https://github.com/hurricanerix/saio-fuse)

2. To cut down on storage costs, only two copies of objects will be stored rather
than the default three.

    a. Since there is the potential to want a higher level of redundency for
important things (say family vacation photos that can never be replaced), there
will be a way to optionally tag containers to have the contents backed up to a
cloud based object storage system like [Rackspace Cloud Files](http://www.rackspace.com/cloud/files).  


Setup
-----

<strong>Note:</strong> The following setup instructions are currently very
unrefined.  They are copied from me setting up Swift@Home on my HP MicroServer.


* Installing dependencies

```Shell
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install curl gcc memcached rsync sqlite3 xfsprogs \
                     git-core libffi-dev python-setuptools

sudo apt-get install python-coverage python-dev python-nose \
                     python-simplejson python-xattr python-eventlet \
                     python-greenlet python-pastedeploy \
                     python-netifaces python-pip python-dnspython \
                     python-mock
```

* Using a partition for storage

OS
/dev/sde1

STORAGE
/dev/sda1
/dev/sdb1
/dev/sdc1
/dev/sdd1

```
swift@swift:~$ sudo mkfs.xfs -f /dev/sda1
meta-data=/dev/sda1              isize=256    agcount=4, agsize=15262348 blks
         =                       sectsz=512   attr=2, projid32bit=0
data     =                       bsize=4096   blocks=61049390, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0
log      =internal log           bsize=4096   blocks=29809, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
swift@swift:~$ sudo mkfs.xfs -f /dev/sdb1
meta-data=/dev/sdb1              isize=256    agcount=4, agsize=15262348 blks
         =                       sectsz=512   attr=2, projid32bit=0
data     =                       bsize=4096   blocks=61049390, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0
log      =internal log           bsize=4096   blocks=29809, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
swift@swift:~$ sudo mkfs.xfs -f /dev/sdc1
meta-data=/dev/sdc1              isize=256    agcount=4, agsize=15262348 blks
         =                       sectsz=512   attr=2, projid32bit=0
data     =                       bsize=4096   blocks=61049390, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0
log      =internal log           bsize=4096   blocks=29809, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
swift@swift:~$ sudo mkfs.xfs -f /dev/sdd1
meta-data=/dev/sdd1              isize=256    agcount=4, agsize=15262348 blks
         =                       sectsz=512   attr=2, projid32bit=0
data     =                       bsize=4096   blocks=61049390, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0
log      =internal log           bsize=4096   blocks=29809, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0

swift@swift:~$ sudo blkid
/dev/sda1: UUID="d13533d9-b387-42d9-b1c5-16034fb78672" TYPE="xfs"
/dev/sdc1: UUID="5d652fd8-878a-4a7a-818a-b4371f0c6690" TYPE="xfs"
/dev/sdd1: UUID="97001c80-3e02-4729-9931-5d583e9ffef9" TYPE="xfs"
/dev/sdb1: UUID="00d23887-cd7a-4f19-89ef-4515afd06944" TYPE="xfs"
/dev/sde1: UUID="824abf13-8861-4c61-9c6d-b7560b772f2d" TYPE="ext4"
/dev/sde5: UUID="62ab15b2-947d-4ad6-bd89-a5712da6b495" TYPE="swap"

add to /etc/fstab
UUID="d13533d9-b387-42d9-b1c5-16034fb78672" /mnt/sda1 xfs noatime,nodiratime,nobarrier,logbufs=8 0 0
UUID="5d652fd8-878a-4a7a-818a-b4371f0c6690" /mnt/sdb1 xfs noatime,nodiratime,nobarrier,logbufs=8 0 0
UUID="97001c80-3e02-4729-9931-5d583e9ffef9" /mnt/sdc1 xfs noatime,nodiratime,nobarrier,logbufs=8 0 0
UUID="00d23887-cd7a-4f19-89ef-4515afd06944" /mnt/sdd1 xfs noatime,nodiratime,nobarrier,logbufs=8 0 0

swift@swift:~$ sudo mkdir /mnt/sda1
swift@swift:~$ sudo mkdir /mnt/sdb1
swift@swift:~$ sudo mkdir /mnt/sdc1
swift@swift:~$ sudo mkdir /mnt/sdd1
swift@swift:~$ sudo chown ${USER}:${USER} /mnt/sda1/
swift@swift:~$ sudo chown ${USER}:${USER} /mnt/sdb1/
swift@swift:~$ sudo chown ${USER}:${USER} /mnt/sdc1/
swift@swift:~$ sudo chown ${USER}:${USER} /mnt/sdd1/

swift@swift:~$ sudo ln -s /mnt/sda1/ /srv/sda1
swift@swift:~$ sudo ln -s /mnt/sdb1/ /srv/sdb1
swift@swift:~$ sudo ln -s /mnt/sdc1/ /srv/sdc1
swift@swift:~$ sudo ln -s /mnt/sdd1/ /srv/sdd1

swift@swift:~$ sudo mkdir /var/run/swift
swift@swift:~$ sudo chown -R ${USER}:${USER} /var/run/swift

swift@swift:~$ sudo chown -R ${USER}:${USER} /srv/sda1
swift@swift:~$ sudo chown -R ${USER}:${USER} /srv/sdb1
swift@swift:~$ sudo chown -R ${USER}:${USER} /srv/sdc1
swift@swift:~$ sudo chown -R ${USER}:${USER} /srv/sdd1
```

Add to /etc/rc.local

```
mkdir -p /var/cache/swift /var/cache/swift2 /var/cache/swift3 /var/cache/swift4
chown swift:swift /var/cache/swift*
mkdir -p /var/run/swift
chown swift:swift /var/run/swift
```

* Getting the code

```Shell
git clone https://github.com/openstack/swift.git
git clone https://github.com/openstack/python-swiftclient.git
git clone https://github.com/gholt/swiftly.git
mkdir middleware
cd middleware/
git clone https://github.com/hurricanerix/swift-inspector.git
git clone https://github.com/gholt/swauth.git
```

* Install the code

```
cd $HOME/python-swiftclient; sudo pip install -r requirements.txt; sudo python setup.py develop; cd -
cd $HOME/swift; sudo python setup.py develop; cd -
sudo pip install -r swift/test-requirements.txt
sudo cp $HOME/swift/doc/saio/rsyncd.conf /etc/
sudo sed -i "s/<your-user-name>/${USER}/" /etc/rsyncd.conf
RSYNC_ENABLE=true
cd $HOME/swift/doc; sudo cp -r saio/swift /etc/swift; cd -
sudo chown -R ${USER}:${USER} /etc/swift
```

* SETUP A BUNCH OF THE OTHER CRAP

```
iswauth-prep -K "swath-admin-pwd"
swauth-prep -K swath-admin-pwd
swift@swift:~/middleware$ swauth-add-user -A http://127.0.0.1:8080/auth/ -K "swath-admin-pwd" -a saio plex "plexpwd"

curl -i -H 'X-Storage-User: saio:plex' -H 'X-Storage-Pass: plexpwd' http://127.0.0.1:8080/auth/v1.0
HTTP/1.1 200 OK
Content-Length: 112
X-Auth-Token-Expires: 86375
X-Auth-Token: AUTH_tkfc09dfe2248d4c588a56015ea1eb59f0
X-Storage-Token: AUTH_tkfc09dfe2248d4c588a56015ea1eb59f0
X-Storage-Url: http://127.0.0.1:8080/v1/AUTH_93e3a69e-3b85-4497-bcfa-012581326726
Content-Type: text/html; charset=UTF-8
X-Trans-Id: tx1db2b0b65bf348839c008-0054865e1e
Date: Tue, 09 Dec 2014 02:27:42 GMT
```
