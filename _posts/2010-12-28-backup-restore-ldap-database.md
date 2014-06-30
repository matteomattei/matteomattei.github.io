---
title: 'Backup &#038; Restore LDAP database'
author: Matteo Mattei
layout: post
permalink: /backup-restore-ldap-database/
categories:
  - linux
  - backup
  - ldap
---
The today question is: *did you ever happened to make an hot backup of an LDAP database?* I will show you how to do it creating an **LDIF** file and then doing the respective restore (in the hope you will not really need it). After all it is quite simple...

BACKUP:
-------

```
ldapsearch -x -b "dc=example,dc=com" -h 192.168.0.1 -D "cn=manager,dc=example,dc=com" -w secret_password "(objectclass=*)" &gt; backup_file.ldif
```

RESTORE:
--------
The new database must be empty!

```
ldapadd -D "cn=manager,dc=example,dc=com" -x -w secret_password -h 192.168.0.1 -f backup_file.ldif
```

Here there is the meaning of the parameters used:

 - **-x** specifies that you want to use the "sample authentication" (rather than SASL)
 - **-b "dc=example,dc=com"** indicates the BaseDN of the server, thus the position where we want to copy all nodes and entries.
 - **-h 192.168.0.1** is the address of the remote LDAP server.
 - **-D &#8220;cn=manager,dc=example,dc=com&#8221;** specifies the LDAP user that will bind to the remote server.
 - **-w secret** lets you to specify the password for the user you have previously chosed.
 - **"(objectclass=*)"** specify all entries in the database.
 - **backup_file.ldif** is the file, in LDIF format, where the backup will be executed.
