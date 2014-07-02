---
title: How to resolve the audio distortion in Skype on Ubuntu 13.04 and previous versions
description: A simple trick to solve audio problems with Skype on Ubuntu
author: Matteo Mattei
layout: post
permalink: /how-to-resolve-the-audio-distortion-in-skype-on-ubuntu-13-04-and-previous-versions/
categories:
  - Audio
  - Skype
  - Ubuntu
---
If you have problems with Skype audio on Ubuntu (distortion, croak, noise...) the simple way to get it fixed is editing the file */etc/pulse/default.pa*, change one line and restart the system.  

From:
```
load-module module-udev-detect use_ucm=0
```

To:
```
load-module module-udev-detect use_ucm=0 tsched=0
```

For simplicity you can execute the following command that will do all the job:

```
sudo sed -i "{s/^load-module module-udev-detect use_ucm=0$/load-module module-udev-detect use_ucm=0 tsched=0/g}" /etc/pulse/default.pa
```

Restart now the system and the Skype audio should work fine!
