---
title: Backup your server on mega.co.nz using megatools
description: In this article I show you how to compile megatools on Debian 7 Wheezy and use it to backup your server data on Mega.co.nz.
author: Matteo Mattei
layout: post
permalink: /backup-your-server-on-mega-co-nz-using-megatools/
img_url:
categories:
  - linux
  - bash
  - backup
  - megatools
---
[**Mega**](http://mega.co.nz) is a wonderful and secure online cloud service that offers 50GB of free storage. So I thought that it would be great using it as additional backup service for my Linux servers. Fortunately there is a good application library and tools to access Mega storage from Linux command line. This tools are called [**megatools**](https://github.com/megous/megatools) and it is released under GPLv2 license.

In this post I will show you how to compile, install and configure a full backup system for your server using Mega and MegaTools.

First of all register an account with Mega at [http://mega.co.nz](http://mega.co.nz) then follow these instructions to compile and install megatools.

```
#!/bin/bash

VERSION="1.9.95"

apt-get install -y build-essentials pkg-config libglib2.0-dev libssl-dev libcurl4-openssl-dev libfuse-dev glib-networking

wget http://megatools.megous.com/builds/megatools-${VERSION}.tar.gz
tar xzf megatools-${VERSION}.tar.gz
cd megatools-${VERSION}
./configure && make && make install && ldconfig
```

*Note: the above instructions are valid for Debian 7 Wheezy and Debian 8 Jessie. In case you have a different Linux distribution please install the required dependencies.*

Now that you have MegaTools installed in /usr/local/bin create a configuration file with your credentials in **/root/.megarc**:

```
[Login]
Username = Your_Mega_Username
Password = Your_Mega_Password
```

Since the password is in clear, it is important to protect the file:

```
chmod 640 /root/.megarc
```

Test now your mega installation and login credentials:

```
root@debian:~# megals 
/Contacts
/Inbox
/Root
/Trash
```

If all goes well you are ready to prepare your backup script. Create a new file called **megabackup.sh** and place it in /root:

{% gist matteomattei/fead2668f8e4c9106e19 %}

Make it executable and accessible only to root:

```
chmod 750 /root/megabackup.sh
```

You only need to set a cron-job now to execute the backup every day:

```
04 04 * * * root /root/megabackup.sh
```

Update 2015-02-14: MegaFuse
---------------------------

I recently found a better tool to accomplish my needings, it is called [MegaFuse](https://github.com/matteoserva/MegaFuse) and it works like a Linux mountpoint.
First of all download all needed dependencies:

```
apt-get install libcrypto++-dev libcurl4-openssl-dev libdb5.1++-dev libfreeimage-dev libreadline-dev libfuse-dev make
```

Then download MegaFuse and compile it:

```
git clone https://github.com/matteoserva/MegaFuse
cd MegaFuse
make
```

Now create a configuration file **/root/.megafuse.conf** with your Mega credentials:

```
USERNAME = your_mega_email
PASSWORD = your_mega_password
MOUNTPOINT = /mnt
```

The above configuration assume you will use /mnt as your mountpoint (change it if you want).

Protect it in the same way:

```
chmod 640 /root/.megafuse.conf
```

And this is the *revisited* script to do the backup:

{% gist matteomattei/6deb97e386d0557c1788 %}

You can now configure the cronjob:

```
04 04 * * * root /root/megafusebackup.sh
```

