---
title: Secure PHP installation disabling dangerous functions
description: A guide on how to make your PHP installation more secure in your production server disabling dangerous functions.
author: Matteo Mattei
layout: post
permalink: /secure-php-installation-disabling-dangerous-functions/
img_url:
categories:
  - php
  - server
  - security
---

Attacks through PHP vulnerabilities are very common and every sysadmin should protect and enforce as much as possible the server infrastructure and PHP configuration to prevent as much as possible these types of attack. Today I show you how to tune PHP configuration to disable some **dangerous** functions and report as less information as possible to outside.

All changes we are going to do are located in *php.ini*:

```
expose_php = Off          # we don't want to let the clients know we are using PHP
display_errors = Off      # in case of error we don't want to show it
register_argc_argv = Off  # for better performance
allow_url_fopen = Off     # no external URL access
allow_url_include = Off   # no external URL access
disable_functions = exec,passthru,shell_exec,system,proc_open,popen,curl_exec,curl_multi_exec,parse_ini_file,show_source # potential dangerous functions to disable
```

After that, restart the web server and create a ```phpinfo()``` page to make sure the new values have been correctly set.