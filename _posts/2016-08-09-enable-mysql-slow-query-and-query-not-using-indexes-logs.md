---
title: Enable MySQL slow query and query not using indexs logs
description: A guide on how to enable mysql slow query and query not using indexes logging.
author: Matteo Mattei
layout: post
permalink: /enable-mysql-slow-query-and-query-not-using-indexes-logs/
img_url:
categories:
  - mysql
  - server
  - debug
---

Sometimes, expecially in production, is important to monitor how your database is performing and in general, when you see the websites are loading slow and/or there is high picks of CPU/RAM on MySQL, a good idea is to enable slow queries and queries not using indexes log. To do it, edit */etc/mysql/my.cnf* on Debian (and derivates) or */etc/my.cnf* on RedHat (and derivates) and add the following lines:

```
slow_query_log_file = /var/log/mysql/mysql-slow.log
slow_query_log = 1
long_query_time = 2
log_queries_not_using_indexes
```

Before restarting MySQL server, create the log file and set the correct permission on it:

```
touch /var/log/mysql/mysql-slow.log
chown mysql.mysql /var/log/mysql/mysql-slow.log
```

Now you can restart MySQL server and check that the new log file (*/var/log/mysql/mysql-slow.log*) is correctly populated:

```
/etc/init.d/mysql restart
```

**NOTE**: I suggest to keep the slow query log enabled only on debugging because it consumes lot of resources and, depending on your application code, the log file might become huge in just few days.
