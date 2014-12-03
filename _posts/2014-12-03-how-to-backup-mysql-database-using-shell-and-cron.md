---
title: How to backup MySQL database using shell and cron
description: A simple script that can be used to backup all MySQL databases
author: Matteo Mattei
layout: post
permalink: /how-to-backup-mysql-database-using-shell-and-cron/
img_url:
categories:
  - linux
  - cron
  - mysql
  - backup
---
Given I did it dozens of times and everytime I have rewritten the code form scratch, I decided to write a simple script to backup all MySQL databases separately in order to avoid to always reinvent the wheel.

The following script must be configured with:

- the MySQL root user.
- the password of MySQL root user.
- the email address to receive the notifications in case of failures.
- the destination folder of the backups.
- the number of copies to keep before overwriting the old backup.

{% gist matteomattei/a02348252d2d47aa5913 %}

NOTE: given the MySQL root password is in clear is important to limit the access to the script:

```
chown root.root mysql_backup.sh
chmod 660 mysql_backup.sh
```

Then, to set a cronjob to do it automatically every day, open */etc/crontab* and add the following line at the bottom:

```
# mysql backup
32 4  *  *  *   root    /root/backup_mysql.sh
```
