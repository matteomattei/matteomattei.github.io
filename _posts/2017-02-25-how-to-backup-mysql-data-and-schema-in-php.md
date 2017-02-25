---
title: How to backup MySQL data and schema in PHP
description: A simple PHP script for backing up a MySQL database including data and schema.
author: Matteo Mattei
layout: post
permalink: /how-to-backup-mysql-data-and-schema-in-php/
categories:
  - mysql
  - php
---
![phpmysql](/public/posts_images/phpmysql_logo.gif)

For a project I am working on, I needed to create a PHP script to export a full MySQL database data and schema. This is probably not the best solution because for these types of things the right tools to use are **mysqldump** and **phpmyadmin** but if you need to do it programmatically using only PHP this might help you.

Here below you can find the code I created for this purpose using **PHP-PDO**:

{% gist matteomattei/908cb5459f74038d962f1c8ace040b51 %}
