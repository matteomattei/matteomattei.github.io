---
title: How to protect wp-content/uploads folder in Wordpress and avoid spam
description: When we use Wordpress in a production LAMP environment is very important to protect the uploads folder because it can be used by attackers to inject scripts that can send thousands of SPAM emails
author: Matteo Mattei
layout: post
permalink: /protect-wp-content-uploads-folder-and-avoid-spam/
categories:
  - linux
  - wordpress
  - email
  - postfix
  - security
  - server
  - spam
  - apache
---

Usually it is not a problem with Wordpress itself but sometimes we install lot of plugins that comes from a not well known origins or that are buggy and they can compromise the entire server. So, after dozens of server sanitizations I am going to summarize all the best practice I found.

 - If you have direct control of the admin area of WP you can restrict the filesystem permissions of *uploads* folder:

```
chmod o-w wp-content/uploads
```

 Remember that in this way you are not able to upload files from the admin area.
 
 - Check the origin of all plugins and make sure to keep your WP installation up to date. In fact attackers often use the last vulnerabilities to attack your server!
 - Use a different user for each domain. This is a general best practice because if an attacker haks your website, he will not be able to access to all other websites in the same server with the same credentials.
 - Deny the usage of scripts in *uploads* folder using a special .htaccess file placed in *wp-content/uploads/*

{% gist matteomattei/3c31ad6f07c821e0b230 %}

