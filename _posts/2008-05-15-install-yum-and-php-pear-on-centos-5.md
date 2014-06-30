---
title: Install yum and php-pear on Centos 5
author: Matteo Mattei
layout: post
permalink: /install-yum-and-php-pear-on-centos-5/
categories:
  - linux
  - php 
  - centos
---
Virtual server like Aruba virtual servers are configured with Centos without yum and without php-pear. Today I have done an assistance to a server of my customer that needed pear installation. It is quite simple to make all work but I don't understand why Aruba's staff have not decided to include yum in their own default configuration server...

Shall we start installing **yum**:

```
mkdir /root/matteo && cd /root/matteo
wget http://mirror.centos.org/centos-5/5/os/i386/CentOS/gmp-4.1.4-10.el5.i386.rpm
rpm -Uvh gmp-4.1.4-10.el5.i386.rpm
wget http://mirror.centos.org/centos-5/5/os/i386/CentOS/readline-5.1-3.el5.i386.rpm
rpm rpm -Uvh readline-5.1-3.el5.i386.rpm
wget http://mirror.centos.org/centos-5/5/os/i386/CentOS/python-2.4.3-27.el5.i386.rpm
rpm -Uvh python-2.4.3-27.el5.i386.rpm
wget http://mirror.centos.org/centos-5/5/os/i386/CentOS/libxml2-2.6.26-2.1.2.8.i386.rpm
rpm -Uvh libxml2-2.6.26-2.1.2.8.i386.rpm
wget http://mirror.centos.org/centos-5/5/os/i386/CentOS/libxml2-python-2.6.26-2.1.2.8.i386.rpm
rpm -Uvh libxml2-python-2.6.26-2.1.2.8.i386.rpm
wget http://mirror.centos.org/centos-5/5/os/i386/CentOS/expat-1.95.8-8.3.el5_4.2.i386.rpm
rpm -Uvh expat-1.95.8-8.3.el5_4.2.i386.rpm
wget http://mirror.centos.org/centos-5/5/os/i386/CentOS/python-elementtree-1.2.6-5.i386.rpm
rpm -Uvh python-elementtree-1.2.6-5.i386.rpm
wget http://mirror.centos.org/centos-5/5/os/i386/CentOS/sqlite-3.3.6-5.i386.rpm
rpm -Uvh sqlite-3.3.6-5.i386.rpm
wget http://mirror.centos.org/centos-5/5/os/i386/CentOS/python-sqlite-1.1.7-1.2.1.i386.rpm
rpm -Uvh python-sqlite-1.1.7-1.2.1.i386.rpm
wget http://mirror.centos.org/centos-5/5/os/i386/CentOS/elfutils-0.137-3.el5.i386.rpm
rpm -Uvh elfutils-0.137-3.el5.i386.rpm
wget http://mirror.centos.org/centos-5/5/os/i386/CentOS/rpm-python-4.4.2.3-18.el5.i386.rpm
rpm -Uvh rpm-python-4.4.2.3-18.el5.i386.rpm
wget http://mirror.centos.org/centos-5/5/os/i386/CentOS/m2crypto-0.16-6.el5.6.i386.rpm
rpm -Uvh m2crypto-0.16-6.el5.6.i386.rpm
wget http://mirror.centos.org/centos-5/5/os/i386/CentOS/python-urlgrabber-3.1.0-5.el5.noarch.rpm
rpm -Uvh python-urlgrabber-3.1.0-5.el5.noarch.rpm
wget http://mirror.centos.org/centos-5/5/os/i386/CentOS/yum-3.2.22-26.el5.centos.noarch.rpm
rpm -Uvh yum-3.2.22-26.el5.centos.noarch.rpm
yum -y update
```

Now it's time to install **php-pear**:

```
yum install php-pear*
```

Ok, in every virtual-host of Plesk (/var/www/vhosts/example.com/conf/httpd.include), there is the directive **open_basedir** that must be configured in the right way adding the pear path:

```
php_admin_value open_basedir "/var/www/vhosts/example.com/httpdocs:/tmp:/usr/share/pear:/local/PEAR"
```

We must also configure pear in */etc/php.ini*

```
include_path=".:/usr/share/pear:/local/PEAR/"
```

At the end you shall restart Apache:

```
/etc/init.d/httpd restart
```
