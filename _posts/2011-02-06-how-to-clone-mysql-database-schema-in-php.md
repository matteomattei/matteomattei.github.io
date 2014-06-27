---
title: How to clone MySQL database schema in PHP
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

```
<?php

/********************* START CONFIGURATION *********************/
$DB_SRC_HOST='localhost';
$DB_SRC_USER='root';
$DB_SRC_PASS='password';
$DB_SRC_NAME='database1';

$DB_DST_HOST='localhost';
$DB_DST_USER='root';
$DB_DST__PASS='password';
$DB_DST_NAME='database2';

/*********************** GRAB OLD SCHEMA ***********************/
$db1 = mysql_connect($DB_SRC_HOST,$DB_SRC_USER,$DB_SRC_PASS) or die(mysql_error());
mysql_select_db($DB_SRC_NAME, $db1) or die(mysql_error());

$result = mysql_query("SHOW TABLES;",$db1) or die(mysql_error());
$buf="set foreign_key_checks = 0;\n";
$constraints='';
while($row = mysql_fetch_array($result))
{
        $result2 = mysql_query("SHOW CREATE TABLE ".$row[0].";",$db1) or die(mysql_error());
        $res = mysql_fetch_array($result2);
        if(preg_match("/[ ]*CONSTRAINT[ ]+.*\n/",$res[1],$matches))
        {
                $res[1] = preg_replace("/,\n[ ]*CONSTRAINT[ ]+.*\n/","\n",$res[1]);
                $constraints.="ALTER TABLE ".$row[0]." ADD ".trim($matches[0]).";\n";
        }
        $buf.=$res[1].";\n";
}
$buf.=$constraints;
$buf.="set foreign_key_checks = 1";

/**************** CREATE NEW DB WITH OLD SCHEMA ****************/
$db2 = mysql_connect($DB_DST_HOST,$DB_DST_USER,$DB_DST_PASS) or die(mysql_error());
$sql = 'CREATE DATABASE '.$DB_DST_NAME;
if(!mysql_query($sql, $db2)) die(mysql_error());
mysql_select_db($DB_DST_NAME, $db2) or die(mysql_error());
$queries = explode(';',$buf);
foreach($queries as $query)
        if(!mysql_query($query, $db2)) die(mysql_error());
?>
```
