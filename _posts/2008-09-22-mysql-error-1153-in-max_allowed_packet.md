---
title: MySQL error 1153 in max_allowed_packet
author: Matteo Mattei
layout: post
permalink: /mysql-error-1153-in-max_allowed_packet/
categories:
  - Linux
  - MySQL
tags:
  - Tricks
---
Today I have got an anomalous error during a database import on mysql:

```
ERROR 1153 (08S01) at line 3854: Got a packet bigger than 'max_allowed_packet' bytes
```

To solve this is sufficient to edit the mysql configuration file (*/etc/my.cnf* on Linux) and fill a suitable big value for **max\_allowed\_packet**. In my case I set it to **100M**.

Restart **mysqld** daemon and now the import will gone fine!
