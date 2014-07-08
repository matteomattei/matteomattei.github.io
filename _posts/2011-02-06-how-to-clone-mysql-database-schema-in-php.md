---
title: How to clone MySQL database schema in PHP
description: In this article I show a simple PHP script that is able to clone a MySQL database schema keeping constraints in a new database.
author: Matteo Mattei
layout: post
permalink: /how-to-clone-mysql-database-schema-in-php/
categories:
  - MySQL
  - PHP
---
![phpmysql](/public/posts_images/phpmysql_logo.gif)

For my client I needed to create a PHP script that can export a full MySQL database schema in another database. This script also need to keep and set constraints.

You only need to configure ```$DB_SRC_*``` and ```$DB_DST_*``` variables to fit your environment.

Here below you can find the code I created for this purpose:

{% gist matteomattei/4d80ba688079eb5affc3 %}
