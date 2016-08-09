---
title: Keep your websites protected with Maldet
description: A guide on how to install and configure Maldet to scan your web server looking for malecious scripts.
author: Matteo Mattei
layout: post
permalink: /keep-your-websites-protected-with-maldet/
img_url:
categories:
  - maldet
  - server
  - web
  - security
---

The LMD (Linux Malware Detect) also called *maldet* is a malware scanner developed by (rxfn.com)[https://www.rfxn.com] for Linux released under the GNU GPLv2 license, that is designed around the threats faced in shared hosted environments.

This guide show you how to install, configure and run maldet once a day in a cronjob:

First of all download the latest version of the maldetect, decompress, and install it:

```
cd /usr/local/src
wget http://www.rfxn.com/downloads/maldetect-current.tar.gz
tar -zxvf maldetect-current.tar.gz
cd maldetect-*
./install.sh
```

Now edit the configuration file */usr/local/maldetect/conf.maldet* and set the following values:

```
email_alert="1"
email_addr="your-email@example.com"
quarantine_hits="1"
quarantine_clean="1"
default_monitor_mode="/path/to/monitor"
```

The default monitor_mode is used by **inotify** in case you want real-time protection, otherwise you can relay only on the cronjob that is already configured in */etc/cron.daily*.

For real-time protection start maldet inotify monitor: ```/etc/init.d/maldet start```

Now update malware definitions and run your first scan:

```
maldet -d                  # update the program
maldet -u                  # update malware definitions
maldet -a /path/to/scan    # scan all files in the path
```

The last command might take lot of time depending on the number of files to analyze.
