---
title: PHP Fatal error with PhpMyAdmin and APC
description: If PhpMyAdmin and APC go in conflict, you need to modify your PHP configuration to disable APC from PhpMyAdmin
author: Matteo Mattei
layout: post
permalink: /php-fatal-error-with-phpmyadmin-and-apc/
categories:
  - Linux
  - MySQL
  - PHP
  - APC
  - Tricks
---
If you are running PhpMyAdmin and APC, it can happens that you get some errors like these:

```
PHP Fatal error:  Call to undefined function PMA_log_user() in /usr/share/webapps/phpMyAdmin/libraries/common.inc.php on line 914
PHP Fatal error:  Call to undefined function PMA_select_language() in /usr/share/webapps/phpMyAdmin/libraries/auth/cookie.auth.lib.php on line 220
PHP Fatal error:  Call to undefined function pma_generate_common_url() in /usr/share/webapps/phpMyAdmin/libraries/header_meta_style.inc.php on line 48
PHP Fatal error:  Call to undefined function PMA_DBI_connect() in /srv/http/librolandia.it/test/phpmyadmin/libraries/common.inc.php on line 916
PHP Fatal error:  Class 'PMA_Error_Handler' not found in /path/to/phpMyAdmin/libraries/common.inc.php on line 58
PHP Fatal error:  Call to undefined function PMA_getenv() in /path/to/phpMyAdmin/libraries/common.inc.php on line 143
```

If this is the case, you need to make some little changes to *disable apc in your phpmyadmin* virtual host:

```
Alias /phpmyadmin "/usr/share/webapps/phpMyAdmin"
<Directory "/usr/share/webapps/phpMyAdmin">
      AllowOverride All
      Options FollowSymlinks
      Order allow,deny
      Allow from all
      php_admin_value open_basedir "/srv/:/tmp/:/usr/share/webapps/:/etc/webapps:/usr/share/pear/"
      php_admin_value apc.enabled 0
</Directory>
```

And also modify your apc filter in *php.ini* under the APC section:

```
[APC]
apc.filter="-/usr/share/webapps/phpMyAdmin/.*"
```

Now restart Apache and you phpMyAdmin should work regularly.
