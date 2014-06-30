---
title: Hide file and directory in apache disabling browsing
author: Matteo Mattei
layout: post
permalink: /hide-file-and-directory-in-apache-disabling-browsing/
categories:
  - apache
  - linux
  - tricks
---
If you want to disable file and directory browsing on your Apache web server in order to prohibit that every users can view the content of a directory (if noindex.php/index.html is present) you need to modify the Apache configuration a little or add a new statement in *.htaccess* file.

I will show you how to do in both cases:

 1.  **Apache configuration: httpd.conf/virtual-hosts**  
Edit your virtualhost adding these rows:

```
<Directory "/home/httpd/html/mydomain/files">
    Options -Indexes
</Directory>
```

 2.  **.htaccess**  
Add in the .htaccess file this row:

```
Options -Indexes
```

In the first case you need to restart apache server.
