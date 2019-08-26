---
title: Monitor SSH access and send email when someone logins
description: Sometimes you need to be advised when someone access your server through SSH. In this article I show you how to monitor that event and do some actions like sending an email.
author: Matteo Mattei
layout: post
permalink: /monitor-ssh-access-and-send-email-when-someone-logins/
img_url:
categories:
  - linux
  - server
  - ssh
  - rsyslog
  - python
---

In order to monitor SSH access we can rely on **rsyslog** given all SSH accesses are recorded in /var/log/auth.log.
Start creating a custom rsyslog configuration `/etc/rsyslog.d/90-ssh.conf` with the following content:

{% gist matteomattei/ff1286c839775fb3ffb4a27a2de8d1f5 %}

Basically we are telling rsyslog to look for lines where the program name is **sshd** and the message contains the **session opened for user**.
Every time the above condition is matched, rsyslog will call the script we are going to create passing the entire log line as parameter.

Assuming we want to receive an email with the user that have been logged, open your editor and create the file `/usr/local/bin/log_access.py`:

{% gist matteomattei/f2cc5a49e38894d81819322bb031cf4e %}

Make the file executable:

```
chmod +x /usr/local/bin/log_access.py
```

Remember to fill the SMTP data at the beginning of the script.
As you can see the above script also logs all logins to `/var/log/logins.log`.

Feel free to do what you want in the python script, the above it's only an example!

Now restart rsyslog and try if everything works as expected.

```
/etc/init.d/rsyslog restart
```

Let me know your work cases and if this article can help you!
