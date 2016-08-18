---
title: Install GoAccess to monitor web server statistics
description: A guide on how to install and configure GoAccess on CentOS to monitor Apache or Nginx web server statistics.
author: Matteo Mattei
layout: post
permalink: /install-and-configure-goaccess-on-centos-to-monitor-apache-statistics/
img_url:
categories:
  - centos
  - server
  - monitor
  - apache
---

[GoAccess](https://goaccess.io/) is a nice tool that parses Apache logs and create a report in various format extracting lot of interesting data and statistics. This guide has been tested on CentOS 6.x but it should be very similar also for other distributions.

First of all install some dependencies given we are going to compile the sources:

```
yum install glib2 glib2-devel glibc make
```

Download the goaccess source code, copile and install it:

```
cd /usr/loca/src
wget http://tar.goaccess.io/goaccess-1.0.2.tar.gz
tar xzf goaccess-1.0.2.tar.gz
cd goaccess-1.0.2
./configure
make
make install
```

Now run goaccess and select the format of the Apache log file from the list it proposes. In case you already know how the Apache output file is generated, you can edit the configuration file */usr/local/etc/goaccess.conf* with the appropriate patterns for **time-format**, **date-format** and **log-format**. In my case I have the following:

```
time-format %H:%M:%S
date-format %d/%b/%Y
log-format %h %^[%d:%t %^] "%r" %s %b
```

Create a *goaccess* folder inside a virtualhost document root (so that it is accessible from the web):

```
mkdir /var/www/vhosts/myhost.com/public_html/goaccess
chown myuser.myuser /var/www/vhosts/myhost.com/public_html/goaccess
```

Now edit */etc/crontab* and add a cronjob for goaccess that runs every 10 minutes:

```
*/10 * * * *    myuser    /usr/local/bin/goaccess -f /usr/local/apache/logs/access_log -a -d -o /var/www/vhosts/myhost.com/public_html/goaccess/index.html &> /dev/null 
```

Generally is a good idea to protect the goaccess folder with a password so that nobody except you can access and see the statistics of the web server.

```
cat << EOF > /var/www/vhosts/myhost.com/public_html/goaccess/.htaccess
AuthType Basic
AuthName "GoAccess"
AuthUserFile /home/myuser/goaccess_htpasswd
Require valid-user
EOF

htpasswd -c /home/myuser/goaccess_htpasswd myuser
```

Now every 10 minutes the statistics of your Apache (or Nginx) web server are correctly parsed and served in a nice HTML web interface!
