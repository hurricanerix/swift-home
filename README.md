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

Currently working to get vagrant to provision the system via a masterless salt
configuration.
