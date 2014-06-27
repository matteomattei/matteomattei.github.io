---
title: Virtual users on vsftpd
author: Matteo Mattei
layout: post
permalink: /virtual-users-on-vsftpd/
categories:
  - Linux
  - ftp
  - virtual
  - vsftp
---
![VSFTPD logo](/public/posts_images/vsftpd_logo.jpg)
I am usually to configure [*vsftp*](http://vsftpd.beasts.org) on web servers to allow FTP access based on domains. Few days ago my client asked me to create multiple FTP users for a single domain every one with a different root folder into that domain.

This is my usual configuration of my **/etc/vsftpd.conf**

```
listen=YES
anonymous_enable=NO
local_enable=YES
virtual_use_local_privs=YES
write_enable=YES
connect_from_port_20=YES
xferlog_enable=YES
pam_service_name=vsftpd
guest_enable=YES
guest_username=www-data
user_sub_token=$USER
local_root=/var/www/$USER
chroot_local_user=YES
hide_ids=YES
force_dot_files=YES
ftpd_banner=Welcome to my private FTP service.
local_umask=022
```

and this is my **/etc/pam.d/vsftpd**

```
auth required pam_pwdfile.so pwdfile /etc/ftpd.passwd
account required pam_permit.so
```

The first time I have created the file **/etc/ftpd.passwd** in this way:

```
htpasswd -c -d -b /etc/ftpd.passwd domain1.com <password>
```

For the next users simply avoid the "**-c**" parameter:

```
htpasswd -d -b /etc/ftpd.passwd domain2.com <password>
```

With this simple configuration all users have these credentials:

 - host: domain1.com
 - username: domain1.com
 - password: password
 - port: 21
 - Root folder: /var/www/domain1/

Now the point is: how can we create multiple users for a single domain each one with a different root folder?  
The answer is pretty simple, follow me!

Create the folder **/var/www/users** and add the following line at the end of */etc/vsftpd.conf*

```
user_config_dir=/var/www/users
```

Inside the folder */var/www/users* create a file for each virtual user (for example the user **user1.domain1.com**) containing a line with the root directory for that user:

```
echo "local_root=/var/www/domain1.com/pub/user1" > /var/www/users/user1.domain1.com
```

Now add the new user/password in */etc/ftpd.passwd* as usual:

```
htpasswd -d -b /etc/ftpd.passwd user1.domain1.com <password>
```

Restart vsftpd server and test your new configuration!
