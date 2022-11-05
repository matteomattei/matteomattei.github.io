---
title: Full web server setup with Debian 11 (Bullseye)
description: In this guide I show you how to setup a web server with all needed services (Nginx, PHP-FPM, MariaDB, PhpMyAdmin, Postfix, Firewall, SFTP and SSL) using Debian 11 Bullseye.
author: Matteo Mattei
layout: post
permalink: /full-web-server-setup-with-debian-11-bullseye/
img_url:
categories:
  - linux
  - server
  - mariadb
  - debian
  - nginx
  - php
  - iptables
  - postfix
  - ssl
  - letsencrypt
  - sftp
---

# Setup bash and update the system

```
apt-get update
apt-get dist-upgrade
```

# Configure hostname correctly

Make sure to have the following two lines (with the same format) at the top of your _/etc/hosts_ file

```
127.0.0.1       localhost.localdomain localhost
xxx.xxx.xxx.xxx web1.myserver.com web1
```

Note: _xxx.xxx.xxx.xxx_ is the public IP address assigned to your server.

# Install all needed packages

```
apt install wget vim git acl screen rsync net-tools pwgen mariadb-server mariadb-client nginx iptables shorewall php php-cli php-curl php-dev php-gd php-imagick php-imap php-memcache php-pspell php-tidy php-xmlrpc php-pear php-fpm php-mbstring php-mysql certbot phpmyadmin python3-pip postfix ntp ca-certificates bsd-mailx tree
```

**Postfix:**

- Select **Internet Site**
- System mail name: (insert here the FQDN, for example web1.myserver.com)

**Web server to reconfigure automatically:**

- Do not select anything and continue

**Configure database for phpmyadmin with dbconfig-common?**

- Select **Yes**

**MySQL application password for phpmyadmin:**

- Leave blank and press **Ok**

# Setup Nginx

Stop Nginx web server:

```
/etc/init.d/nginx stop
```

Backup Nginx configuration:

```
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
```

Add the following lines in _/etc/nginx/nginx.conf_ after _tcp_nopush on;_:

```
tcp_nodelay on;
keepalive_timeout 65;
```

And the following lines after _gizp on;_:

```
gzip_disable "msie6";

gzip_vary on;
gzip_proxied any;
gzip_comp_level 6;
gzip_buffers 16 8k;
gzip_http_version 1.1;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

# max body size
client_max_body_size 10M;
```

Copy some nginx configuration files:

```
mkdir -p /etc/nginx/certs
ln -s /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/nginx/certs/server.crt
ln -s /etc/ssl/private/ssl-cert-snakeoil.key /etc/nginx/certs/server.key

mkdir -p /etc/nginx/global
wget -q -O - https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian11/nginx/global/codeigniter_production.conf > /etc/nginx/global/codeigniter_production.conf
wget -q -O - https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian11/nginx/global/codeigniter_testing.conf > /etc/nginx/global/codeigniter_testing.conf
wget -q -O - https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian11/nginx/global/common.conf > /etc/nginx/global/common.conf
wget -q -O - https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian11/nginx/global/dokuwiki.conf > /etc/nginx/global/dokuwiki.conf
wget -q -O - https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian11/nginx/global/phpmyadmin.conf > /etc/nginx/global/phpmyadmin.conf
wget -q -O - https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian11/nginx/global/plainphp.conf > /etc/nginx/global/plainphp.conf
wget -q -O - https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian11/nginx/global/ssl.conf > /etc/nginx/global/ssl.conf
wget -q -O - https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian11/nginx/global/wordpress.conf > /etc/nginx/global/wordpress.conf
```

Restart Nginx:

```
/etc/init.d/nginx restart
```

# Setup let's encrypt

```
pip3 install tld
certbot register --agree-tos -m <your@email>
```

# Setup MariaDB

Secure MariaDB installation:

```
mysql_secure_installation
```

- Enter current password for root (enter for none): **[ENTER]**
- Switch to unix_socket authentication [Y/n] **Y**
- Change the root password? [Y/n] **Y**
- New password: _MARIAB_ROOT_PASSWORD_
- Re-enter new password: _MARIAB_ROOT_PASSWORD_
- Remove anonymous users? [Y/n] **Y**
- Disallow root login remotely? [Y/n] **Y**
- Remove test database and access to it? [Y/n] **Y**
- Reload privilege tables now? [Y/n] **Y**

Set MariaDB root password in a configuration file (the same password configured before!)

```
cat << EOF > /root/.my.cnf
[client]
user = root
password = MARIADB_ROOT_PASSWORD
EOF
```

_Optional_ enable MySQL slow query logging (often useful during slow page load debugging):

```
sed -i "{s/^#slow_query_log_file /slow_query_log_file /g}" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i "{s/^#long_query_time /long_query_time /g}" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i "{s/^#log_slow_verbosity /log_slow_verbosity /g}" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i "{s/^#log-queries-not-using-indexes/log-queries-not-using-indexes/g}" /etc/mysql/mariadb.conf.d/50-server.cnf
```

MySQL is now configured, so restart it:

```
/etc/init.d/mariadb restart
```

# Configure Shorewall firewall rules

Copy the default configuration for one interface:

```
cd /usr/share/doc/shorewall/examples/one-interface
cp interfaces /etc/shorewall/
cp policy /etc/shorewall/
cp rules /etc/shorewall/
cp zones /etc/shorewall/
```

Now open _/etc/shorewall/policy_ file and change the line:

```
net             all             DROP            info
```

removing _info_ directive given it fills the system logs:

```
net             all             DROP
```

Now open _/etc/shorewall/rules_ and add the following rules at the bottom of the file:

```
HTTP/ACCEPT     net             $FW
HTTPS/ACCEPT    net             $FW
SSH/ACCEPT      net             $FW
```

NOTE: in case you want to allow ICMP (Ping) traffic from a specific remote hosts you need to add a rule similar to the following where xxx.xxx.xxx.xxx is the remote IP address, before the **Ping(DROP)** rule:

```
Ping(ACCEPT)    net:xxx.xxx.xxx.xxx       $FW
```

Now edit _/etc/default/shorewall_ and change **startup=0** to **startup=1**
You are now ready to start the firewall:

```
/etc/init.d/shorewall start
```

# Setup Postfix

Stop postfix server:

```
/etc/init.d/postfix stop
```

Edit _/etc/mailname_ and set your server domain name, for example:

```
server1.mycompany.com
```

Restart Postfix:

```
/etc/init.d/postfix start
```

# Select correct timezone

```
dpkg-reconfigure tzdata
# Select your timezone (for example Europe/Rome)
```

# Log rotation

In order to correctly log files you need to adjust logrotate configuration for Nginx:

```
cat << EOF >> /etc/logrotate.d/nginx
/home/*/*/logs/*.log {
        daily
        missingok
        rotate 14
        compress
        delaycompress
        notifempty
        create 0640 www-data adm
        sharedscripts
        prerotate
                if [ -d /etc/logrotate.d/httpd-prerotate ]; then \
                        run-parts /etc/logrotate.d/httpd-prerotate; \
                fi \
        endscript
        postrotate
                invoke-rc.d nginx rotate >/dev/null 2>&1
        endscript
}
EOF
```

# Install virtualhost manager

```
wget -q -O - https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian11/lemp_manager.py > /usr/local/sbin/lemp_manager.py
chmod 770 /usr/local/sbin/lemp_manager.py
```

Download also the tools that will be used with cron:

```
cd /root/cron_scripts
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian11/cron_scripts/backup_mysql.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian11/cron_scripts/mysql_optimize.sh
chmod 770 *.sh
```

# Configure CRON

Edit _/etc/crontab_ and add the following lines at the bottom:

```
# mysql optimize tables
3  4  *  *  7   root    /root/cron_scripts/mysql_optimize.sh

# mysql backup
32 4  *  *  *   root    /root/cron_scripts/backup_mysql.sh
```

# How to use virtualhost manager

You can use the virtualhost manager for adding or removing virtualhosts:

```
# lemp_manager

Usage:
/usr/local/sbin/lemp_manager -a|--action=<action> [-d|--domain=<domain>] [-A|--alias=<alias>] [options]

Parameters:
	-a|--action=ACTION
		it is mandatory
	-d|--domain=domain.tld
		can be used only with [add_domain, remove_domain, add_alias, get_certs, get_info]
	-A|--alias=alias.domain.tld
		can be used only with [add_alias, remove_alias, get_info]

Actions:
	add_domain	Add a new domain
	add_alias	Add a new domain alias to an existent domain
	remove_domain	Remove an existent domain
	remove_alias	Remove an existent domain alias
	get_certs	Obtain SSL certificate and deploy it
	get_info	Get information of a domain or a domain alias (username)

Options:
	-f|--fakessl	Use self signed certificate (only usable with [add_domain, add_alias])
```
