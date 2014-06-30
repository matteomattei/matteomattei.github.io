---
title: How to transfer an entire website via ftp with recursive lftp
author: Matteo Mattei
layout: post
permalink: /how-to-transfer-an-entire-big-website-via-ftp-with-recursive-lftp/
categories:
  - linux
  - ftp
  - tricks
---
In these days I have to transfer some big websites from a server to another and the only way to do it was an FTP connection because the destination server did not provide any other type of access. Because of the number of files was big (about 12GB) I have created a little script to use with **lftp** opened into a **screen session** to don't busy the terminal *for days*.

So I created a script called *sendfiles.sh* with the following content:

```
set ftp:ssl-allow no
open -u username,password example.com
mirror -c -R /source-path /destination-path
quit
```

Where the following fields are respectively:

**username**: user name for ftp access  
**password**: password for ftp access  
**example.com**: ftp destination server  
**source-path**: source path on local server  
**destination-path**: remote path on the ftp (where / is the ftp rootdir)

To run the script is sufficient to open a **screen session** (if you want to leave the process in background on the source server) and issue this command:

```
lftp -f sendfiles.sh
```
