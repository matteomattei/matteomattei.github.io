---
title: How to use google apps in WordPress on Bluehost
author: Matteo Mattei
layout: post
permalink: /how-to-use-google-apps-in-wordpress-on-bluehost/
categories:
  - Wordpress
  - Bluehost
  - Mail
  - Tricks
---
In these days I spent a lot of time looking for a solution of changing the admin email address in [Bluehost](http://www.bluehost.com) and I found a working solution! The problem is that Bluehost uses *Exim* as mail server that is configured to require a valid and registered email address.

This is my scenario:

 - Some domains with *mx* record pointed to google apps (I will take *myprivatedomain.com* as example).
 - No mailbox created on Bluehost because I have already created some mailboxes with google apps.
 - *myprivatedomain.com* with *info@myprivatedomain.com* as admin email set in *Settings -> General* inside Bluehost panel.

At this point, every email sent from any comments has this header:

```
user <user@boxXXX.bluehost.com>
```

I want to change it in order to have this address in my comments:

```
info <info@myprivatedomain.com>
```

These are the steps to follow:

 1. Log-in to Bluehost cpanel and go to **Mail -> MX Entry**. Here select your host (*myprivatedomain.com*), add these MX records as in the picture below and make sure to set **Remote Mail Exchanger**: 
    *   1 ASPMX.L.GOOGLE.COM.
    *   5 ALT1.ASPMX.L.GOOGLE.COM
    *   5 ALT2.ASPMX.L.GOOGLE.COM
    *   10 ASPMX2.GOOGLEMAIL.COM
    *   10 ASPMX3.GOOGLEMAIL.COM
    
    ![MX Google Bluehost](/public/posts_images/mx_google_bluehost_1.jpg)
 
 2. Now the e-mail delivery should just work. However, if you want to change the "*From email*" field, install the [mail from](http://wordpress.org/extend/plugins/mail-from/) plugin and configure it in this way:
     - Sender Name -> YourName
     - User Name -> info
     - Domain Name -> myprivatedomain.com
        
    ![Wordpress Mail From Plugin](/public/posts_images/wp_mail_from_plugin.jpg)

That's all! Now try to post a comment and look at your mailbox.
        
**Update 2013/11/02:**
As Amanda highlited in the comments below, it's also necessary to add an account for each address set up in Google Apps. So, go to *Bluehost's cPanel > Email Accounts*, then add an account for each address. Adding the addresses to your Bluehost accounts, even though they won't actually work there, seems to make them *trusted*, and allows you to send with those addresses.
