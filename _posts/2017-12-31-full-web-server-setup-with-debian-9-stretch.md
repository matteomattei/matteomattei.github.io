---
title: Full web server setup with Debian 9 (Stretch)
description: In this guide I show you how to setup a web server with all needed services (Apache, Varnish, PHP, MariaDB, PhpMyAdmin, Postfix, Firewall, VSFTP and SSL) using Debian 9 Stretch.
author: Matteo Mattei
layout: post
permalink: /full-web-server-setup-with-debian-9-stretch/
img_url:
categories:
  - linux
  - server
  - mariadb
  - varnish
  - debian
  - php
  - iptables
  - postfix
  - ssl
  - letsencrypt
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
apt-get install vim git acl screen rsync net-tools php mysql-server mysql-client apache2 iptables phpmyadmin varnish shorewall vsftpd php-cli php-curl php-dev php-gd php-imagick php-imap php-memcache php-pspell php-recode php-tidy php-xmlrpc php-pear postfix apg ca-certificates bsd-mailx
```

**MariaDB/PhpMyAdmin:**

 - web server to reconfigure automatically: **apache2**
 - configure database for phpmyadmin with dbconfig-common? **Yes**
 - MySQL application password for phpmyadmin: [blank]

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
cat << "EOF" > /etc/vsftpd.conf
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
EOF
```

Create an empty chroot_list file:

```
mkdir /etc/vsftpd
touch /etc/vsftpd/chroot_list
```

Install PAM module for virtual users:

```
apt-get install libpam-pwdfile
```

And configure it creating the file ```/etc/pam.d/vsftpd_local_and_virtual``` with this content:

```
# Standard behaviour for ftpd(8).
auth    required        pam_listfile.so item=user sense=deny file=/etc/ftpusers onerr=succeed

# first try to authenticate local users
auth    sufficient      pam_unix.so

# if that failed, login with virtual user
auth    required        pam_pwdfile.so  pwdfile /etc/vsftpd/passwd

# pam_pwdfile doesn't come with account, so we just permit on success
account required        pam_permit.so
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

Edit */etc/apache2/mods-enabled/mpm_prefork.conf*:

```
<IfModule mpm_prefork_module>
        StartServers             5
        MinSpareServers          5
        MaxSpareServers          10
        MaxRequestWorkers        150
        MaxConnectionsPerChild   10000
</IfModule>
```

Edit */etc/apache2/ports.conf* and change the port **80** with **8080** since we are going to use Varnish:

```
Listen 8080
```

Change the port (from **80** to **8080**) also in the default virtual host */etc/apache2/sites-enabled/000-default.conf*

Enable useful Apache modules:
```
a2enmod ssl
a2enmod rewrite
a2enmod headers
a2enmod deflate
a2enmod proxy
a2enmod proxy_http
```

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

Backup your */etc/varnish/default.vcl* and create a new one with this content:

```
vcl 4.0;
import std;

# Default backend definition. Set this to point to your content server.
backend default {
    .host = "127.0.0.1";
    .port = "8080";
    .connect_timeout = 600s;
    .first_byte_timeout = 600s;
    .between_bytes_timeout = 600s;
}

sub vcl_recv {
    # Happens before we check if we have this in cache already.
    #
    # Typically you clean up the request here, removing cookies you don't need,
    # rewriting the request, etc.

    if ((client.ip != "127.0.0.1" && std.port(server.ip) == 80) &&
        (
          (req.http.host ~ "localhost")
          # ENSURE HTTPS - DO NOT REMOVE THIS LINE
        )
    ){
        set req.http.x-redir = "https://" + req.http.host + req.url;
        return (synth(750, ""));
    }
}

sub vcl_synth {
  # Listen to 750 status from vcl_recv.
  if (resp.status == 750) {
    # Redirect to HTTPS with 301 status.
    set resp.status = 301;
    set resp.http.Location = req.http.x-redir;
    return(deliver);
  }
}

sub vcl_backend_response {
    # Happens after we have read the response headers from the backend.
    #
    # Here you clean the response headers, removing silly Set-Cookie headers
    # and other mistakes your backend does.
}

sub vcl_deliver {
    # Happens when we have all the pieces we need, and are about to send the
    # response to the client.
    #
    # You can do accounting or modifying the final object here.
}
```

Now edit */etc/default/varnish* and set the **DAEMON_OPTS** variable like this:

```
DAEMON_OPTS="-a :80 \
             -T localhost:6082 \
             -f /etc/varnish/default.vcl \
             -S /etc/varnish/secret \
             -s malloc,256m"
```

Now we have to make some changes also to systemd scripts (this step is mandatory for Debian Stretch!) since systemd does not consider /etc/default/varnish settings.

Edit */lib/systemd/system/varnish.service* and change port 6081 with port 80:

```
[Unit]
Description=Varnish HTTP accelerator
Documentation=https://www.varnish-cache.org/docs/4.1/ man:varnishd

[Service]
Type=simple
LimitNOFILE=131072
LimitMEMLOCK=82000
ExecStart=/usr/sbin/varnishd -j unix,user=vcache -F -a :80 -T localhost:6082 -f /etc/varnish/default.vcl -S /etc/varnish/secret -s malloc,256m
ProtectSystem=full
ProtectHome=true
PrivateTmp=true
PrivateDevices=true

[Install]
WantedBy=multi-user.target
```

Restart Varnish:

```
systemctl daemon-reload
systemctl restart varnish.service
```

Setup MariaDB
===========

Secure MariaDB installation:

```
mysql_secure_installation
```

- Enter current password for root (enter for none): **[ENTER]**
- Set root password? [Y/n] **Y**
- Write your *MARIAB_ROOT_PASSWORD*
- Remove anonymous users? [Y/n] **Y**
- Disallow root login remotely? [Y/n] **Y**
- Remove test database and access to it? [Y/n] **Y**
- Reload privilege tables now? [Y/n] **Y**

Instruct MariaDB to use native password:
```
mysql -u root mysql -e "update user set plugin='mysql_native_password' where user='root'; flush privileges;"
```

Set MariaDB root password in a configuration file (the same password configured before!)
```
cat << EOF > /root/.my.cnf
[client]
user = root
password = MARIADB_ROOT_PASSWORD
EOF
```
Enable MySQL slow query logging (often useful during slow page load debugging):

```
sed -i "{s/^#slow_query_log_file /slow_query_log_file /g}" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i "{s/^#long_query_time /long_query_time /g}" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i "{s/^#log_slow_rate_limit /log_slow_rate_limit /g}" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i "{s/^#log_slow_verbosity /log_slow_verbosity /g}" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i "{s/^#log-queries-not-using-indexes/log-queries-not-using-indexes/g}" /etc/mysql/mariadb.conf.d/50-server.cnf
```

MySQL is now configured, so restart it:

```
/etc/init.d/mysql restart
```

Fix for PhpMyAdmin redirecting to port 8080
=====================================
If you try to access to *http://yoursitename/phpmyadmin* you are redirected to *http://yoursitename:8080/phpmyadmin* that will not work unless you open the firewall rule for port 8080 as described below. This because the web server is actually running on port 8080. To workaround this and have the PhpMyAdmin working on port 80 you need to force the redirect:
```
cat << "EOF" > /etc/phpmyadmin/conf.d/fix-redirection.php
<?php
$cfg['PmaAbsoluteUri'] = $_SERVER['REQUEST_SCHEME'].'://'.$_SERVER['SERVER_NAME'].'/phpmyadmin';
EOF
```

Configure Shorewall firewall rules
==================================
Copy the default configuration for one interface:

```
cd /usr/share/doc/shorewall/examples/one-interface
cp interfaces /etc/shorewall/
cp policy /etc/shorewall/
cp rules /etc/shorewall/
cp zones /etc/shorewall/

cd /usr/share/doc/shorewall6/examples/one-interface
cp interfaces /etc/shorewall6/
cp policy /etc/shorewall6/
cp rules /etc/shorewall6/
cp zones /etc/shorewall6/
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
HTTPS/ACCEPT     net             $FW
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

Then, in order to monitor mail traffic coming from PHP you need to edit */etc/php/7.0/apache2/php.ini*. Go to **[mail function]** section and set the following two options:

```
sendmail_path = /usr/local/bin/sendmail-wrapper
auto_prepend_file = /usr/local/bin/env.php
```

Now create the two files above in */usr/local/bin*:

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

Add also */usr/local/bin/* to the open_basedir php list in */etc/apache2/conf-enabled/phpmyadmin.conf*

```
php_admin_value open_basedir /usr/share/phpmyadmin/:/etc/phpmyadmin/:/var/lib/phpmyadmin/:/usr/local/bin/
```

Restart Postfix:

```
/etc/init.d/postfix start
```

Let's encrypt
==========
In order to SSL free certificates with let's encrypt install the powerful (and simple) dehydrated tool:
```
cd /root
git clone https://github.com/lukas2511/dehydrated.git
cd dehydrated
touch domains.txt
cp docs/examples/config .
```

Prepare Apache2 configuration for letsencrypt:
```
cat << EOF > /etc/apache2/conf-available/dehydrated.conf
Alias /.well-known/acme-challenge /var/www/dehydrated
<Directory /var/www/dehydrated>
        Options None
        AllowOverride None

        # Apache 2.x
        <IfModule !mod_authz_core.c>
                Order allow,deny
                Allow from all
        </IfModule>

        # Apache 2.4
        <IfModule mod_authz_core.c>
                Require all granted
        </IfModule>
</Directory>
EOF
```

Enable new config and reload Apache
```
a2enconf dehydrated
systemctl reload apache2
```

Log rotation
============
In order to correctly log files you need to adjust lograte configuration for Apache:

```
cat << EOF >> /etc/logrotate.d/apache2
/var/www/vhosts/*/logs/access*.log
{
    rotate 30
    missingok
    size 10M
    compress
    delaycompress
    sharedscripts
    postrotate
        /etc/init.d/apache2 reload > /dev/null
    endscript
}

/var/www/vhosts/*/logs/error*.log
{
    rotate 3
    missingok
    compress
    delaycompress
    size 2M
    sharedscripts
    postrotate
        /etc/init.d/apache2 reload > /dev/null
    endscript
}
EOF
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
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian9/LAMP/ADD_ALIAS.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian9/LAMP/ADD_DOMAIN.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian9/LAMP/ADD_FTP_VIRTUAL_USER.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian9/LAMP/ADD_SSL.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian9/LAMP/ALIAS_LIST.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian9/LAMP/CLEAN_VARNISH_CACHE.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian9/LAMP/DEL_ALIAS.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian9/LAMP/DEL_DOMAIN.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian9/LAMP/DEL_FTP_VIRTUAL_USER.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian9/LAMP/DOMAIN_LIST.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian9/LAMP/MYSQL_CREATE.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian9/LAMP/UPDATE_ALL_FTP_PASSWORD.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian9/LAMP/UPDATE_FTP_PASSWORD.sh
chmod 770 *.sh
```

Download also the tools that will be used with cron:

```
cd /root/cron_scripts
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian9/LAMP/cron_scripts/backup_mysql.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian9/LAMP/cron_scripts/mysql_optimize.sh
chmod 770 *.sh
```

 - Edit */root/ADD_DOMAIN.sh* and change **ADMIN_EMAIL** variable with your email address.


Configure CRON
==============
Edit */etc/crontab* and add the following lines at the bottom:

```
# mysql optimize tables
3  4  *  *  7   root    /root/cron_scripts/mysql_optimize.sh

# mysql backup
32 4  *  *  *   root    /root/cron_scripts/backup_mysql.sh

# letsencrypt
50 2 * * *      root    /root/dehydrated/dehydrated -c > /dev/null
```
