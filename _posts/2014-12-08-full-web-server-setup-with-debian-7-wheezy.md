---
title: Full web server setup with Debian 7 (Wheezy) 
description: In this guide I show you how to setup a web server with all needed services (Apache, Varnish, PHP, MySQL, PhpMyAdmin, Postfix, Firewall, VSFTP) using Debian 7 Wheezy.
author: Matteo Mattei
layout: post
permalink: /full-web-server-setup-with-debian-7-wheezy/
img_url:
categories:
  - linux
  - server
  - mysql
  - varnish
  - debian
  - php
  - iptables
  - postfix
---

Setup bash and update the system
================================

```
cp /etc/skel/.bashrc /root/.bashrc
apt-get update
apt-get dist-upgrade
```

Configure hostname correctly
============================
Make sure to have the following two lines (with the same format) at the top of your */etc/hosts* file

```
127.0.0.1       localhost.localdomain localhost
xxx.xxx.xxx.xxx web1.myserver.com web1
```

Note: *xxx.xxx.xxx.xxx* is the public IP address assigned to your server.

Install all needed packages
===========================
```
apt-get install php5 mysql-server mysql-client apache2 iptables phpmyadmin varnish shorewall vsftpd php5-cli php5-curl php5-dev php5-gd php5-idn php5-imagick php5-imap php5-memcache php5-ming php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xcache php5-xmlrpc php-apc php-pear php-xml-rpc postfix apg ca-certificates heirloom-mailx
```

**MySQL/PhpMyAdmin:**

 - mysql root password: xxx
 - repeat mysql root password: xxx
 - web server to reconfigure automatically: **apache2**
 - configure database for phpmyadmin with dbconfig-common? **Yes**
 - Password of the database's administrative user: xxx
 - Password for phpmyadmin: xxx
 - Password confirmation: xxx

**Postfix:**

 - Select **Internet Site**
 - System mail name: (insert here the FQDN, for example web1.myserver.com)


Setup FTP
=========
Stop VSFTP server:

```
/etc/init.d/vsftpd stop
```

Create backup configuration:

```
mv /etc/vsftpd.conf /etc/vsftpd.conf.backup
```

Add new configuration:

```
listen=YES
listen_port=21
anonymous_enable=NO
local_enable=YES
guest_enable=YES
guest_username=nobody
user_sub_token=$USER
local_root=/var/www/vhosts/$USER
virtual_use_local_privs=YES
user_config_dir=/etc/vsftpd/users
pam_service_name=vsftpd_local_and_virtual
chroot_local_user=YES
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd/chroot_list
ftpd_banner=Welcome to my ftp server
write_enable=YES
download_enable=YES
dirlist_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
xferlog_file=/var/log/xferlog
connect_from_port_20=YES
connect_timeout=60
data_connection_timeout=300
idle_session_timeout=300
local_max_rate=0
max_clients=0
max_per_ip=3
```

Create an empty chroot_list file:

```
touch /etc/vsftpd/chroot_list
```

Start VSFTP server:

```
/etc/init.d/vsftpd start
```

Setup Apache
============
Stop Apache web server:

```
/etc/init.d/apache2 stop
```

Backup Apache configuration:

```
cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.backup
```

Edit the following lines in */etc/apache2/apache2.conf*

 - From **Timeout 300** to **Timeout 45**
 - From **KeepAliveTimeout 5** to **KeepAliveTimeout 15**
 - Change the **mpm_prefork_module** section like the following:

```
  <IfModule mpm_prefork_module>
      StartServers         5
      MinSpareServers      5
      MaxSpareServers      10
      ServerLimit          400
      MaxClients           400
      MaxRequestsPerChild  10000
  </IfModule>
```

Edit */etc/apache2/ports.conf* and change the port **80** with **8080** since we are going to use Varnish:

```
NameVirtualHost *:8080
Listen 8080
```

Change the port (from **80** to **8080**) also in the default virtual host */etc/apache2/sites-enabled/000-default*
Now restart Apache:

```
/etc/init.d/apache2 restart
```

Setup Varnish
=============
Stop Varnish daemon:

```
/etc/init.d/varnish stop
```

Open */etc/varnish/default.vcl* and make sure the backend section is like this:

```
backend default {
    .host = "127.0.0.1";
    .port = "8080";
    .connect_timeout = 600s;
    .first_byte_timeout = 600s;
    .between_bytes_timeout = 600s;
}
```

Now edit */etc/default/varnish* and set the **DAEMON_OPTS** variable like this:

```
DAEMON_OPTS="-a :80 \
                -T localhost:6082 \
                -f /etc/varnish/default.vcl \
                -p thread_pools=4 \
                -p thread_pool_max=1500 \
                -p listen_depth=2048 \
                -p lru_interval=1800 \
                -h classic,169313 \
                -p max_restarts=6 \
                -p connect_timeout=600 \
                -p send_timeout=2000 \
                -s malloc,2G"
```

Restart Varnish:

```
/etc/init.d/varnish restart
```

Setup MySQL
===========
MySQL is already configured. You only need to log slow queries (that is often usefult during slow load page investigation). Todo it, open */etc/mysql/my.cnf* and decomment the following two lines:

```
log_slow_queries       = /var/log/mysql/mysql-slow.log
long_query_time = 2

```

Configure Shorewall firewall rules
==================================
Copy the default configuration for one interface:

```
cp /usr/share/doc/shorewall/examples/one-interface/interfaces /etc/shorewall/interfaces
cp /usr/share/doc/shorewall/examples/one-interface/policy /etc/shorewall/policy
cp /usr/share/doc/shorewall/examples/one-interface/rules /etc/shorewall/rules
cp /usr/share/doc/shorewall/examples/one-interface/zones /etc/shorewall/zones
```

Now open */etc/shorewall/policy* file and change the line:

```
net             all             DROP            info
```

removing *info* directive given it fills the system logs:

```
net             all             DROP
```

Now open */etc/shorewall/rules* and add the following rules at the bottom of the file:

```
HTTP/ACCEPT     net             $FW
SSH/ACCEPT      net             $FW
FTP/ACCEPT      net             $FW

# real apache since varnish listens on port 80
#ACCEPT         net             $FW             tcp             8080
```

NOTE: in case you want to allow ICMP (Ping) traffic from a specific remote hosts you need to add a rule similar to the following where xxx.xxx.xxx.xxx is the remote IP address, before the **Ping(DROP)** rule:

```
Ping(ACCEPT)    net:xxx.xxx.xxx.xxx       $FW
```

Now edit */etc/default/shorewall* and change **startup=0** to **startup=1**
You are now ready to start the firewall:

```
/etc/init.d/shorewall start
```

Setup Postfix
=============
Stop postfix server:

```
/etc/init.d/postfix stop
```

Edit */etc/mailname* and set your server domain name, for example:

```
server1.mycompany.com
```

Then, in order to monitor mail traffic coming from PHP you need to edit */etc/php5/apache2/php.ini*. Go to **[mail function]** section and set the following two options:

```
sendmail_path = /usr/local/bin/sendmail-wrapper
auto_prepend_file = /usr/local/bin/env.php
```

Now create the two files above:

**sendmail-wrapper**:

```
#!/bin/sh
logger -p mail.info sendmail-wrapper.sh: site=${HTTP_HOST}, client=${REMOTE_ADDR}, script=${SCRIPT_NAME}, pwd=${PWD}, uid=${UID}, user=$(whoami)
/usr/sbin/sendmail -t -i $*
```

**env.php**:

```
<?php
putenv("HTTP_HOST=".@$_SERVER["HTTP_HOST"]);
putenv("SCRIPT_NAME=".@$_SERVER["SCRIPT_NAME"]);
putenv("SCRIPT_FILENAME=".@$_SERVER["SCRIPT_FILENAME"]);
putenv("DOCUMENT_ROOT=".@$_SERVER["DOCUMENT_ROOT"]);
putenv("REMOTE_ADDR=".@$_SERVER["REMOTE_ADDR"]);
?>
```

Now make they both have executable flag:

```
chmod +x /usr/local/bin/sendmail-wrapper
chmod +x /usr/local/bin/env.php
```

Add also */usr/local/bin/* to the open_basedir php list in **/etc/apache2/conf.d/phpmyadmin.conf**

```
php_admin_value open_basedir /usr/share/phpmyadmin/:/etc/phpmyadmin/:/var/lib/phpmyadmin/:/usr/local/bin/
```

Restart Postfix:

```
/etc/init.d/postfix start
```

Prepare environment
===================
Create all needed directories and files

```
mkdir /root/cron_scripts
mkdir -p /var/www/vhosts
mkdir -p /etc/vsftpd/users
touch /etc/vsftpd/passwd
```

Now download all tools to manage the server locally:

```
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/LAMP/ADD_ALIAS.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/LAMP/ADD_DOMAIN.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/LAMP/ADD_ALIAS.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/LAMP/ADD_FTP_VIRTUAL_USER.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/LAMP/ALIAS_LIST.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/LAMP/DEL_ALIAS.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/LAMP/DEL_DOMAIN.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/LAMP/DEL_FTP_VIRTUAL_USER.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/LAMP/DOMAIN_LIST.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/LAMP/MYSQL_CREATE.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/LAMP/UPDATE_ALL_FTP_PASSWORD.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/LAMP/UPDATE_FTP_PASSWORD.sh
chmod 770 *.sh
```

Download also the tools that will be used with cron:

```
cd /root/cron_scripts
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/LAMP/cron_scripts/backup_mysql.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/LAMP/cron_scripts/mysql_optimize.sh
chmod 770 *.sh
```

 - Edit */root/ADD_DOMAIN.sh* and change **ADMIN_EMAIL** variable with your email address.
 - Edit */root/MYSQL_CREATE.sh* and change the variable **MYSQL_ROOT_PASSWORD** with your MySQL root password.
 - Edit */root/cron_scripts/backup_mysql.sh* and change the variable **DB_PASSWORD** with your MySQL root password and **MAIL_NOTIFICATION** with your email address.
 - Edit */root/cron_scripts/mysql_optimize.sh* and change the variable **MYSQL_ROOT_PASSWORD** with your MySQL root password.

Configure CRON
==============
Edit */etc/crontab* and add the following lines at the bottom:

```
# mysql optimize tables
3  4  *  *  7   root    /root/mysql_optimize.sh

# mysql backup
32 4  *  *  *   root    /root/backup_mysql.sh

```

