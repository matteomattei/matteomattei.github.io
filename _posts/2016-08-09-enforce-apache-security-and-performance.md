---
title: Enforce Apache security and performance
description: A quick guide on how to enforce Apache security and performance
author: Matteo Mattei
layout: post
permalink: /enforce-apache-security-and-performance/
img_url:
categories:
  - apache
  - server
  - security
---

Production Apache web servers need to be well configured for what regards security and performance. Here below a quick tips to make your servers more secure and performant.

First of all you need to verify if you are using **prefork** module:

```
apachectl -V | grep -i mpm
```

If prefork is enabled, you should see a line like this:

```
Server MPM:     prefork
```

If it is, I wrote a simple script to calculate the number of **MaxClients** your server can support:

{% gist matteomattei/d2335a3ee5d13d0d1acb285806624ea9 %}

Basically this number is calculated with this formula:

**(TOTAL_RAM - MYSQL_RAM - 50MB) / APACHE_RAM**

So, edit */etc/apache2/apache2.conf* on Debian/Ubuntu and */etc/httpd/conf/httpd.conf* on RedHat/CentOS and set the prefork section like this:

```
<IfModule prefork.c>
    StartServer 5
    MinSpareServers 5
    MaxSpareServers 10
    MaxClients 300            # value calculated
    MaxRequestPerChild 3000   # 3000 is a good number, avoid to leave it at 0
</IfModule>
```

Set now some parameters that affects security and performances.
Depending on your distribution they can be already set in the following files:

Debian/Ubuntu:

 - */etc/apache2/apache2.conf*
 - */etc/apache2/conf.d/security*

RedHat/CentOS:

 - */etc/httpd/conf/httpd.conf*
 - */etc/httpd/conf/extra/httpd-default.conf*

```
ServerTokens Prod
ServerSignature Off
HostnameLookups Off
Timeout 45
KeepAlive On
MaxKeepAliveRequests 100
KeepAliveTimeout 15
```

Now test apache configuration and if all goes well, restart the web server:

```
apachectl configtest

/etc/init.d/httpd restart    # RedHat/CentOS
/etc/init.d/apache2 restart  # Debian/Ubuntu
```
