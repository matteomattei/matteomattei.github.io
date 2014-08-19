---
title: How to log email sent from PHP through mail() function
description: In a LAMP environment is it often useful to log from where virtual host the email are sent. The script contained in this article shows how to do it.
author: Matteo Mattei
layout: post
permalink: /how-to-log-email-sent-from-php-through-mail-function/
categories:
  - bash
  - linux
  - php
  - email
  - postfix
  - security
  - server
  - spam
---
If you have a website in a virtualhost environment that is under attack and starts sending tons of emails, is sometimes difficult to understand from where the attack is started (especially if you have several virtual hosts). However with a little PHP script you can understand from which folder the attack is coming.

Create the following file in a secure place and call it *phpsendmail*:

{% gist matteomattei/f362f7902a0084934dfb %}

Now create the log file and set the correct permissions:

```
touch /var/log/mail_php.log
chmod 777 /var/log/mail_php.log
chmod 777 /path/to/phpsendmail
```

Now you have to edit the php.ini configuration (*/etc/php5/apache2/php.ini* in Debian). Search the **[mail_function]** section and set it in this way:

```
[mail function]
;SMTP = localhost
;smtp_port = 25
sendmail_path = /path/to/phpsendmail
```

Now you can restart Apache and look at */var/log/mail_php.log* file.  
Its content shoud be someting similar to this:

```
2013-02-03 17:50:57  To: mail1@domain1.com From: mail2@domain2.com ==> /var/www/vhosts/domain1/httpdocs
2013-02-03 17:50:59  To: mail3@domain3.com From: mail4@domain4.com ==> /var/www/vhosts/domain2/httpdocs/libraries
2013-02-03 17:51:02  To: mail5@domain5.com From: mail6@domain6.com ==> /var/www/vhosts/domain2/httpdocs/assets
```
Update August 2014
------------------
I found a more convenient way to do it... and it saved my life with some servers that were affected by thousands of SPAM emails. You just need to create a couple of files:

{% gist matteomattei/33f51bdcd68519414a60 %}

Now, in the same way as above set the correct permissions and edit php.ini:

```
chmod +x /usr/local/bin/sendmail-wrapper
chmod +x /usr/loca/bin/env.php
```

```
[mail function]
;SMTP = localhost
;smtp_port = 25
sendmail_path = /usr/local/bin/sendmail-wrapper
auto_prepend_file = /usr/local/bin/env.php
```

Restart Apache and look at /var/log/mail.info. Now the content is similar to the following:

```
Aug 18 20:35:42 vps74403 logger: sendmail-wrapper.sh: site=www.example.com, client=77.221.130.44, script=/WP/wp-content/uploads/flags/plugin.php, pwd=/var/www/vhosts/example.com/WP/wp-content/uploads/flags, uid=, user=www-data
Aug 18 20:35:42 vps74403 logger: sendmail-wrapper.sh: site=www.example.com, client=77.221.130.44, script=/WP/wp-content/uploads/flags/plugin.php, pwd=/var/www/vhosts/example.com/WP/wp-content/uploads/flags, uid=, user=www-data
Aug 18 20:35:42 vps74403 logger: sendmail-wrapper.sh: site=www.example.com, client=77.221.130.44, script=/WP/wp-content/uploads/flags/plugin.php, pwd=/var/www/vhosts/example.com/WP/wp-content/uploads/flags, uid=, user=www-data
```
