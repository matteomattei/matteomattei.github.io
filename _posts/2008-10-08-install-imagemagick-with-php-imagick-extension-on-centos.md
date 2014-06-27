---
title: Install imagemagick with PHP imagick extension on CentOS
author: Matteo Mattei
layout: post
permalink: /install-imagemagick-with-php-imagick-extension-on-centos/
categories:
  - Linux
  - PHP
tags:
  - centos
  - imagick
---
To install imagemagick with PHP imagick extension on Linux CentOS you must follow these steps:

```
yum install ImageMagick
yum install ImageMagick-devel
pecl install imagick
```

If you have an error like this:  
```
root@myhost [~]# pecl install imagick
downloading imagick-3.0.1.tgz ...
Starting to download imagick-3.0.1.tgz (93,920 bytes)
.....................done: 93,920 bytes
13 source files, building
running: phpize
Configuring for:
PHP Api Version:         20090626
Zend Module Api No:      20090626
Zend Extension Api No:   220090626
Please provide the prefix of Imagemagick installation [autodetect] :
building in /var/tmp/pear-build-root/imagick-3.0.1
running: /root/tmp/pear/imagick/configure --with-imagick
checking for egrep... grep -E
checking for a sed that does not truncate output... /bin/sed
checking for cc... cc
checking for C compiler default output file name... a.out
checking whether the C compiler works... configure: error: cannot run C compiled programs.
If you meant to cross compile, use `--host'.
See `config.log' for more details.
ERROR: `/root/tmp/pear/imagick/configure --with-imagick' failed
```

Look at your /tmp folder... pretty surely it is mounted with **noexec** flag. Remount it without **noexec** and retry:  

```
mount -o remount,rw /tmp
```

At the end of the installation, create an inclusion file for **imagick.so** module and restart apache:

```
echo "extension=imagick.so" > /etc/php.d/imagick.ini
/etc/init.d/httpd restart
```

Test the correct load of the imagick module with:

```
php -m | grep imagick
```
