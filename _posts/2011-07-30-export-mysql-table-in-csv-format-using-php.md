---
title: Export MySQL table in CSV format using PHP
description: In this article I report a little PHP script to export a MySQL table in CSV format
author: Matteo Mattei
layout: post
permalink: /export-mysql-table-in-csv-format-using-php/
categories:
  - Linux
  - MySQL
  - PHP
  - backup
  - dump
---
The following PHP code is intended to be used to export a MySQL table in CSV format in order to be used with MS Excel.

```
$link = mysql_connect($mysql_host,$mysql_user,$mysql_pass) or die('Could not connect: '.mysql_error());
mysql_select_db($mysql_db,$link) or die('Could not select database: '.$mysql_db);

$query = "SELECT * FROM $tablename ORDER BY id";
$result = mysql_query($query) or die("Error executing query: ".mysql_error());
$row = mysql_fetch_assoc($result);
$line = "";
$comma = "";
foreach($row as $name => $value)
{
        $line .= $comma . '"' . str_replace('"', '""', $name) . '"';
        $comma = ";";
}
$line .= "\n";
$out = $line;

mysql_data_seek($result, 0);

while($row = mysql_fetch_assoc($result))
{
        $line = "";
        $comma = "";
        foreach($row as $value)
        {
                $line .= $comma . '"' . str_replace('"', '""', $value) . '"';
                $comma = ";";
        }
        $line .= "\n";
        $out.=$line;
}
header("Content-type: text/csv");
header("Content-Disposition: attachment; filename=listino.csv");
echo $out;
exit;
```
