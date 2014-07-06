---
title: Backup Virtualhosts and MySQL data on Plesk server and store images in a remote FTP server
description: This is a script that let you backup all virtualhosts and mysql data on remote server via FTP keeping last 7 days.
author: Matteo Mattei
layout: post
permalink: /backup-virtualhosts-and-mysql-data-on-plesk-server-and-store-images-in-a-remote-ftp-server/
categories:
  - backup
  - centos
  - plesk
  - ftp
  - mysql
---

I am working for a client that needs a system to backup a CentOS server hosted by OVH that uses Plesk. I didn't know that Plesk already implemented a way to backup all domains and MySQL data so I cerated a script to do that:

{% gist matteomattei/3d718b8a1ea692b632f3 %}

As you can see this script keeps the last 7 days of backups.
However after googling a while I found that the same thing could be done directly using a Plesk utility called **pleskbackup**, so I developed an alterlate script that uses it:

{% gist matteomattei/cf0dabd87aa34fd4d10a %}

I hope it can help you.
