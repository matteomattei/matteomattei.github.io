---
title: Full web server setup with Debian 10 (Buster)
description: In this guide I show you how to setup a web server with all needed services (Apache, PHP-FPM, MariaDB, PhpMyAdmin, Postfix, Firewall, SFTP and SSL) using Debian 10 Buster.
author: Matteo Mattei
layout: post
permalink: /full-web-server-setup-with-debian-10-buster/
img_url:
categories:
  - linux
  - server
  - mariadb
  - debian
  - php
  - iptables
  - postfix
  - ssl
  - letsencrypt
  - sftp
---

# Setup bash and update the system

```
cp /etc/skel/.bashrc /root/.bashrc
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
apt install wget vim git acl screen rsync net-tools pwgen php mariadb-server mariadb-client apache2 iptables shorewall php php-cli php-curl php-dev php-gd php-imagick php-imap php-memcache php-pspell php-recode php-tidy php-xmlrpc php-pear php-fpm postfix ca-certificates bsd-mailx
```

**Postfix:**

- Select **Internet Site**
- System mail name: (insert here the FQDN, for example web1.myserver.com)

# Setup chrooted SFTP jail

Create `sftponly` group:

```
addgroup --system sftponly
```

Edit `/etc/ssh/sshd_config` and make sure to have the following lines:

```
PasswordAuthentication yes
ChallengeResponseAuthentication no
```

Then change the _Subsystem_ line with the following:

```
Subsystem sftp internal-sftp
```

And create the section to allow chrooted SFTP access to the users belonging to the `sftponly` group.

```
Match Group sftponly
    ChrootDirectory %h
    X11Forwarding no
    AllowTcpForwarding no
    ForceCommand internal-sftp
```

Now restart ssh server:

```
/etc/init.d/sshd restart
```

In order to have a working sftp jail, there are 4 rules to follow:

1. every user home directory must belong to **root:root**
2. every user home directory must have **0755** permissions
3. every user must belong to **sftponly** group
4. every subfolder in user home directory must belong to **\${USER}:sftponly**

# Setup Apache

Stop Apache web server:

```
/etc/init.d/apache2 stop
```

Backup Apache configuration:

```
cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.backup
```

Edit the following lines in _/etc/apache2/apache2.conf_

- From **Timeout 300** to **Timeout 45**
- From **KeepAliveTimeout 5** to **KeepAliveTimeout 15**

Create a configuration for phpmyadmin:

```
cat << EOF > /etc/apache2/conf-available/phpmyadmin.conf
Alias /phpmyadmin /usr/share/phpmyadmin

<Directory /usr/share/phpmyadmin>
    Options SymLinksIfOwnerMatch
    DirectoryIndex index.php

    <IfModule mod_php5.c>
        <IfModule mod_mime.c>
            AddType application/x-httpd-php .php
        </IfModule>
        <FilesMatch ".+\.php$">
            SetHandler application/x-httpd-php
        </FilesMatch>

        php_value include_path .
        php_admin_value upload_tmp_dir /var/lib/phpmyadmin/tmp
        php_admin_value open_basedir /usr/share/phpmyadmin/:/etc/phpmyadmin/:/var/lib/phpmyadmin/:/usr/share/php/php-gettext/:/usr/share/php/php-php-gettext/:/usr/share/javascript/:/usr/share/php/tcpdf/:/usr/share/doc/phpmyadmin/:/usr/share/php/phpseclib/
        php_admin_value mbstring.func_overload 0
    </IfModule>
    <IfModule mod_php.c>
        <IfModule mod_mime.c>
            AddType application/x-httpd-php .php
        </IfModule>
        <FilesMatch ".+\.php$">
            SetHandler application/x-httpd-php
        </FilesMatch>

        php_value include_path .
        php_admin_value upload_tmp_dir /var/lib/phpmyadmin/tmp
        php_admin_value open_basedir /usr/share/phpmyadmin/:/etc/phpmyadmin/:/var/lib/phpmyadmin/:/usr/share/php/php-gettext/:/usr/share/php/php-php-gettext/:/usr/share/javascript/:/usr/share/php/tcpdf/:/usr/share/doc/phpmyadmin/:/usr/share/php/phpseclib/
        php_admin_value mbstring.func_overload 0
    </IfModule>

</Directory>

# Authorize for setup
<Directory /usr/share/phpmyadmin/setup>
    <IfModule mod_authz_core.c>
        <IfModule mod_authn_file.c>
            AuthType Basic
            AuthName "phpMyAdmin Setup"
            AuthUserFile /etc/phpmyadmin/htpasswd.setup
        </IfModule>
        Require valid-user
    </IfModule>
</Directory>

# Disallow web access to directories that don't need it
<Directory /usr/share/phpmyadmin/templates>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/libraries>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/setup/lib>
    Require all denied
</Directory>
EOF
```

Configure the proper Apache modules and configurations:

```
a2dismod mpm_worker
a2dismod mpm_prefork

a2enmod mpm_event
a2enmod ssl
a2enmod rewrite
a2enmod headers
a2enmod deflate
a2enmod proxy
a2enmod proxy_http
a2enmod proxy_fcgi
a2enmod http2
a2enmod setenvif

a2enconf security
a2enconf php7.3-fpm
a2enconf phpmyadmin
```

Now restart Apache:

```
/etc/init.d/apache2 restart
```

# Setup MariaDB

Secure MariaDB installation:

```
mysql_secure_installation
```

- Enter current password for root (enter for none): **[ENTER]**
- Set root password? [Y/n] **Y**
- Write your _MARIAB_ROOT_PASSWORD_
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

# Install phpMyAdmin

The version of phpmyadmin coming with the distribution is not updated so I prefer to install the latest manually:

```
export VER="4.9.0.1"
cd /tmp
wget https://files.phpmyadmin.net/phpMyAdmin/${VER}/phpMyAdmin-${VER}-all-languages.tar.gz
tar xvf phpMyAdmin-${VER}-all-languages.tar.gz
rm -f phpMyAdmin-${VER}-all-languages.tar.gz
mv phpMyAdmin* /usr/share/phpmyadmin
mkdir -p /var/lib/phpmyadmin/tmp
chown -R www-data:www-data /var/lib/phpmyadmin
mkdir /etc/phpmyadmin/
cp /usr/share/phpmyadmin/config.sample.inc.php  /usr/share/phpmyadmin/config.inc.php
```

Now edit the file `/usr/share/phpmyadmin/config.inc.php` and set secret passphrase and temporary directory:

```
// http://www.passwordtool.hu/blowfish-password-hash-generator
$cfg['blowfish_secret'] = 'SECRET_HERE';
[...]
$cfg['TempDir'] = '/var/lib/phpmyadmin/tmp';
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

# Let's encrypt

In order to get SSL free certificates with let's encrypt install the powerful (and simple) dehydrated tool:

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

# Log rotation

In order to correctly log files you need to adjust logrotate configuration for Apache:

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

# Prepare environment

Create all needed directories and files

```
mkdir /root/cron_scripts
mkdir -p /var/www/vhosts
```

Now download all tools to manage the server locally:

```
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian10/LAMP/ADD_ALIAS.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian10/LAMP/ADD_DOMAIN.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian10/LAMP/ADD_SSL.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian10/LAMP/ALIAS_LIST.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian10/LAMP/DEL_ALIAS.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian10/LAMP/DEL_DOMAIN.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian10/LAMP/DOMAIN_LIST.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian10/LAMP/MYSQL_CREATE.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian10/LAMP/UPDATE_SFTP_PASSWORD.sh
chmod 770 *.sh
```

Download also the tools that will be used with cron:

```
cd /root/cron_scripts
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian9/LAMP/cron_scripts/backup_mysql.sh
wget https://raw.githubusercontent.com/matteomattei/servermaintenance/master/Debian9/LAMP/cron_scripts/mysql_optimize.sh
chmod 770 *.sh
```

- Edit _/root/ADD_DOMAIN.sh_ and change **ADMIN_EMAIL** variable with your email address.

# Configure CRON

Edit _/etc/crontab_ and add the following lines at the bottom:

```
# mysql optimize tables
3  4  *  *  7   root    /root/cron_scripts/mysql_optimize.sh

# mysql backup
32 4  *  *  *   root    /root/cron_scripts/backup_mysql.sh

# letsencrypt
50 2 * * *      root    /root/dehydrated/dehydrated -c > /dev/null
```
