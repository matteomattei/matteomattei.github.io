---
title: How to configure a secure SFTP chroot jail
description: Instead of using FTP, if we have SSH we can configure a secure SFTP with chroot jail at no cost
author: Matteo Mattei
layout: post
permalink: /how-to-configure-a-secure-sftp-chroot-jail/
img_url:
categories:
  - linux
  - server
  - ssh
  - sftp
---

If you have a linux server, openssh is almost always already present, so without any other tool you can configure a super secure SFTP chroot jail to allow your users to access the server limiting the visibility to their home directory.

Start creating a new linux system group called sftponly:

```
groupadd --system sftponly
```

We create a system group because we want an ID lower than 1000 so that every new user will take a sequential UID.
Now open _/etc/ssh/sshd_config_ and make sure to have the following lines:

```
PasswordAuthentication yes
ChallengeResponseAuthentication no
```

Now replace the line starting with **Subsystem** with the following:

```
Subsystem sftp internal-sftp
```

This line tells SSH to use its internal sftp subsytem to mange SFTP connections.

Now add the following lines at the bottom of the file:

```
Match Group sftponly
    ChrootDirectory %h
    X11Forwarding no
    AllowTcpForwarding no
    ForceCommand internal-sftp
```

Basically the above section describes how to handle connections from users belonging to _sftponly_ group.
In particular we are telling SSH to chroot the users to their home directory, does not allow X11 and TCP forwarding and force to use the internal sftp interface.

After do that, restart ssh server to make the changes active:

```
/etc/init.d/ssh restart
```

Now the SFTP server is ready to be used but you must keep in mind some important rules otherwise it will not work!

1. every user home directory must belong to **root:root**
2. every user home directory must have **0755** permissions
3. every user must belong to **sftponly** group
4. every first level folder in user home directory must belong to **\${USER}:sftponly**

Let's do an example: create a new user _matteo_ with no login shell, assign it to _sftpgroup_ group and set a password:

```
useradd --create-home --shell /usr/sbin/nologin --user-group matteo
usermod --groups sftponly matteo
passwd matteo
```

Assuming you want the following permissions:

```
mkdir /home/matteo/pics    # write access by user matteo
mkdir /home/matteo/musics  # write access by user matteo
mkdir /home/matteo/logs    # read only access by user matteo
```

Configure the folders in this way:

```
chown root:root /home/matteo
chmod 755 /home/matteo
chown matteo:sftponly /home/matteo/pics
chown matteo:sftponly /home/matteo/musics
chown matteo:sftponly /home/matteo/logs
chmod 555 /home/matteo/logs
```

Now try with _sftp_ command line client or with _filezilla_ and test your new SFTP server.
Files created from an SFTP session will belong to matteo:matteo.

As you can understand, this configuration is very useful for web servers running with _PHP-FPM_ where every VirtualHost runs with its own user and privileges, so you can restrict the access by user with a secure SFTP connection and at the same time avoid all the problems related to the files permissions management and the configuration of a separated FTP/FTPS server.

I hope you enjoy this article. If you like it please leave a comment!
