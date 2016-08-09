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
wget http://sourceforge.net/projects/goaccess/files/0.7.1/goaccess-0.7.1.tar.gz/download -O goaccess-0.7.1.tar.gz
tar xzf goaccess-0.7.1.tar.gz
cd goaccess-0.7.1
./configure
make
make install
```

Now run goaccess and select the format of the Apache log file from the list it proposes. In case you already know how the Apache output file is generated, you can create the *~/.goaccessrc* with the appropriate patterns for **date_format** and **log_format**. In my case I have the following:

```
color_scheme 1
date_format %d/%b/%Y
log_format %h %^[%d:%^] "%r" %s %b
```

Create a *goaccess* folder inside a virtualhost document root (so that it is accessible from the web):

```
mkdir /var/www/vhosts/myhost.com/public_html/goaccess
chown myuser.myuser /var/www/vhosts/myhost.com/public_html/goaccess
```

Now edit */etc/crontab* and add a cronjob for goaccess that runs every 10 minutes:

```
*/10 * * * *    myuser     /usr/local/bin/goaccess -p /home/myuser/.goaccessrc -d -H -M -o --real-os -f /var/log/apache2/access_log > /var/www/vhosts/myhost.com/public_html/goaccess/index.html
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