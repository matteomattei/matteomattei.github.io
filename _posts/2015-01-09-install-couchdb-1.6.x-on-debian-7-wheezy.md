---
title: Install CouchDB 1.6.x on Debian 7 (Wheezy) 
description: These are the working instructions to install CouchDB 1.6.x on Debian 7 (Wheezy)
author: Matteo Mattei
layout: post
permalink: /install-couchdb-1.6.x-on-debian-7-wheezy/
img_url:
categories:
  - linux
  - server
  - couchdb
  - debian
  - erlang
---

Setup repository and install all dependencies
------------------------------------------------------

```
echo "deb http://packages.erlang-solutions.com/debian wheezy contrib" >> /etc/apt/sources.list
wget -qO - http://packages.erlang-solutions.com/debian/erlang_solutions.asc | apt-key add -
apt-get update
apt-get install -y build-essential curl erlang-nox erlang-dev libmozjs185-1.0 libmozjs185-dev libcurl4-openssl-dev libicu-dev
```

Create CouchDB account
-----------------------------

```
useradd -d /var/lib/couchdb couchdb
mkdir -p /usr/local/{lib,etc}/couchdb /usr/local/var/{lib,log,run}/couchdb /var/lib/couchdb
chown -R couchdb:couchdb /usr/local/{lib,etc}/couchdb /usr/local/var/{lib,log,run}/couchdb
chmod -R g+rw /usr/local/{lib,etc}/couchdb /usr/local/var/{lib,log,run}/couchdb
```

Install CouchDB
-------------------

```
wget http://apache.panu.it/couchdb/source/1.6.1/apache-couchdb-1.6.1.tar.gz
tar xzf apache-couchdb-1.6.1.tar.gz
cd apache-couchdb-1.6.1
./configure --prefix=/usr/local --with-js-lib=/usr/lib --with-js-include=/usr/include/js --enable-init
make && make install
```

Create symlinks and start the database
----------------------------------------------

```
chown couchdb:couchdb /usr/local/etc/couchdb/local.ini
ln -s /usr/local/etc/init.d/couchdb /etc/init.d/couchdb
/etc/init.d/couchdb start
update-rc.d couchdb defaults
```

Verify that all is working fine
----------------------------------

```
curl http://127.0.0.1:5984/
```

The output should be like this:

```
{"couchdb":"Welcome","uuid":"5da242ff50cecec904d6caf36be34194","version":"1.6.1","vendor":{"name":"The Apache Software Foundation","version":"1.6.1"}}
```

Finalize setup
-----------------
In order to connect from remote edit */usr/local/etc/couchdb/local.ini* and change 

```
bind_address 127.0.0.1
```

to:

```
bind_address to 0.0.0.0
```

Restart the database:

```
service couchdb restart
```

And from a web browser visit the CouchDB Futon:

```
http://HOST:5984/_utils
```

