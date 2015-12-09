---
title: Configure production web sever with Debian 8 Jessie 
description: A step by step guide on how to configure a production ready web server with Debian 8 Jessie 
author: Matteo Mattei
layout: post
permalink: /configure-production-web-server-with-debian-8-jessie/
img_url:
categories:
  - server
  - postfix
  - mysql
  - php
  - apache
  - firewall
---
This is the list of the services we are going to install and configure:

- Apache
- PHP-FPM
- MySQL
- Postfix
- PhpMyAdmin
- Shorewall
- Nodejs
- Couchdb

First of all configure ssh key access to your server. Make sure to have a rsa key-pair in *~/.ssh/* folder in your pc. Assuming xxx.xxx.xxx.xxx is the public ip address of your server, execute the following command to copy the public key:

```
ssh-copy-id root@xxx.xxx.xxx.xxx
```

Setup root shell configuration and update the system:

```
cp /etc/skel/.bashrc /root/.bashrc
apt-get update
apt-get upgrade
apt-get dist-upgrade
```

Configure a fully qualified domain name (FQDN) in */etc/hosts*:

```
127.0.0.1       localhost.localdomain localhost
xxx.xxx.xxx.xxx srv1.mycompany.com srv1
```
where xxx.xxx.xxx.xxx is the public IP address assigned by your provider.

Install MySQL server and client:

```
apt-get install mysql-server mysql-client

New password for the MySQL "root" user: xxx
Repeat password for the MySQL "root" user: xxx

[...]

[Warning] Using unique option prefix key_buffer instead of key_buffer_size is deprecated and will be removed in a future release. Please use the full name instead.
```

Correct the above MySQL configuration warning:

```
sed -i "{s/^key_buffer/key_buffer_size/g}" /etc/mysql/my.cnf
```

Enable MySQL slow query logging:

```
sed -i "{s/^#slow_query_log_file /slow_query_log_file /g}" /etc/mysql/my.cnf
sed -i "{s/^#slow_query_log /slow_query_log /g}" /etc/mysql/my.cnf
sed -i "{s/^#long_query_time /long_query_time /g}" /etc/mysql/my.cnf
sed -i "{s/^#log_queries_not_using_indexes/log_queries_not_using_indexes/g}" /etc/mysql/my.cnf
```

Restart MySQL server:

```
systemctl restart mysql
```

Install Apache (**mpm-worker** is needed for using **PHP-FPM**):

```
apt-get install apache2-mpm-worker
```

Install PHP-FPM and related PHP extensions:

```
apt-get install libapache2-mod-fastcgi php5-fpm php5 php-pear php5-readline php5-gd php5-mysql php5-mcrypt mcrypt php5-imagick imagemagick php5-curl
```

Configure Apache server properly:

```
sed -i "{s#^Timeout 300#Timeout 45#g}" /etc/apache2/apache2.conf
sed -i "{s#^KeepAliveTimeout 5#KeepAliveTimeout 15#g}" /etc/apache2/apache2.conf
sed -i "{s#^ServerTokens OS#ServerTokens Minimal#g}" /etc/apache2/conf-enabled/security.conf
sed -i "{s#^ServerSignature On#ServerSignature Off#g}" /etc/apache2/conf-enabled/security.conf
```

Enable needed Apache modules and restart Apache server:

```
a2enmod actions fastcgi alias proxy prxy_http ssl
service apache2 restart
```

Configure correct umask for PHP-FPM and restart the daemon:

```
sed -i "{s#^\[Service\]#[Service]\nUMask=0022#g}" /etc/systemd/system/multi-user.target.wants/php5-fpm.service

systemctl daemon-reload
systemctl restart php5-fpm.service
```

Install and configure PhpMyAdmin:

```
apt-get install phpmyadmin

Web server to reconfigure automatically: [apache2]
Configure database for phpmyadmin with dbconfig-common? [Yes]
Password of the database's administrative user: [xxx]
MySQL application password for phpmyadmin: [xxx]
Password confirmation: [xxx]
```

Make MySQL more secure:

```
mysql_secure_installation

Enter current password for root (enter for none): [xxx]
Change the root password? [Y/n] [n]
Remove anonymous users? [Y/n] [Y]
Disallow root login remotely? [Y/n] [Y]
Remove test database and access to it? [Y/n] [Y]
Reload privilege tables now? [Y/n] [Y]
```

Create a group for SFTP and configure SFTP in a secure manner with chroot directory:

```
addgroup sftponly

cat <<EOF >> /etc/ssh/sshd_config
Match Group sftponly
   ChrootDirectory %h
   ForceCommand internal-sftp -u 0022
   AllowTcpForwarding no
   AllowAgentForwarding no
   PermitTunnel no
   X11Forwarding no
EOF

service ssh restart
```

Install and configure firewall:

```
apt-get install shorewall

cd /usr/share/doc/shorewall/examples/one-interface
cp interfaces /etc/shorewall/interfaces
cp policy /etc/shorewall/policy
cp rules /etc/shorewall/rules
cp zones /etc/shorewall/zones

echo "HTTP/ACCEPT net \$FW" >> /etc/shorewall/rules
echo "HTTPS/ACCEPT net \$FW" >> /etc/shorewall/rules
echo "SSH/ACCEPT  net \$FW" >> /etc/shorewall/rules

sed -i "{s#^startup=0#startup=1#g}" /etc/default/shorewall

systemctl restart shorewall
```

Install and configure Postfix:

```
apt-get install postfix heirloom-mailx

General type of mail configuration: [Internet Site]
System mail name: [your FQDN as reported by hostname -f]
```

Install CouchDb dependencies:

```
apt-get install libmozjs185-1.0 libmozjs185-dev build-essential curl erlang-nox erlang-dev libnspr4 libnspr4-0d libnspr4-dev libcurl4-openssl-dev curl libicu-dev
```

Now create CouchDb account:

```
useradd -d /var/lib/couchdb couchdb
mkdir -p /usr/local/{lib,etc}/couchdb /usr/local/var/{lib,log,run}/couchdb /var/lib/couchdb
chown -R couchdb:couchdb /usr/local/{lib,etc}/couchdb /usr/local/var/{lib,log,run}/couchdb
chmod -R g+rw /usr/local/{lib,etc}/couchdb /usr/local/var/{lib,log,run}/couchdb
```

Download and install CouchDb:

```
cd /root
wget http://apache.panu.it/couchdb/source/1.6.1/apache-couchdb-1.6.1.tar.gz
tar xzf apache-couchdb-1.6.1.tar.gz
cd apache-couchdb-1.6.1
./configure --prefix=/usr/local --with-js-lib=/usr/lib --with-js-include=/usr/include/js --enable-init
make && make install
```

Configure startup script for CouchDB and run it:

```
chown couchdb:couchdb /usr/local/etc/couchdb/local.ini
ln -s /usr/local/etc/init.d/couchdb /etc/init.d/couchdb
/etc/init.d/couchdb start
update-rc.d couchdb defaults
```

Configure Apache Proxy to forward all requests on a particular domain to localhost:5984 (CouchDb) over SSL. To do it, create a new virtual host for your db URL creating */etc/apache2/site-available/db.mysite.com.conf* with the following content:


```
<VirtualHost *:443>
    ServerAdmin info@matteomattei.com
    ServerName db.mysite.com

    ErrorLog /var/www/vhosts/db.mysite.com/logs/error.log
    CustomLog /var/www/vhosts/db.mysite.com/logs/access.log combined

    SSLEngine On
    SSLCertificateFile      /etc/ssl/certs/ssl-cert-snakeoil.pem
    SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key

    <FilesMatch "\.(cgi|shtml|phtml|php)$">
        SSLOptions +StdEnvVars
    </FilesMatch>
    <Directory /usr/lib/cgi-bin>
        SSLOptions +StdEnvVars
    </Directory>
    BrowserMatch "MSIE [2-6]" \
        nokeepalive ssl-unclean-shutdown \
        downgrade-1.0 force-response-1.0
    BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown

    AllowEncodedSlashes On
    ProxyRequests Off
    ProxyPreserveHost On
    KeepAlive On
    <Proxy *>
        Order deny,allow
        Allow from all
    </Proxy>
    ProxyPass / http://localhost:5984/ nocanon
    ProxyPassReverse / http://localhost:5984/
</VirtualHost>
```

Create the folder */var/www/vhosts/db.mysite.com/logs* for storing logs and restart Apache server:


```
mkdir -p /var/www/vhosts/db.mysite.com/logs
service apache2 restart
```

Now your couchdb futon interface should be available at [https://db.mysite.com/_utils](https://db.mysite.com/_utils). Remember however to setup authentication in */usr/local/etc/couchdb/local.ini* in order to limit the db access to only authenticated users.

Install now the latest version of nodejs:

```
apt-get install -y curl
curl -sL https://deb.nodesource.com/setup_5.x | bash -
apt-get install -y nodejs
```

Install pm2 node process manager globally:

```
npm install pm2 -g
```
