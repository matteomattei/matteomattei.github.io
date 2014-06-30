---
title: Codesourcery G++ for ColdFire on OpenSuse 10.3 and some problems during IDE installation
author: Matteo Mattei
layout: post
permalink: /codesourcery-g_for-coldfire-on-opensuse-10-3-and-some-problems-during-ide-installation/
categories:
  - embedded
  - linux
  - opensuse
---
In these days at work we are evaluating to buy a cross-compiler IDE of ColdFire developed by CodeSourcery G++. The development environment is substantially Eclipse optimized for that cross-compiler. During installation of the package we have discovered a lot of problems running the IDE installation and the next license installation.

From the official site must download the *.bin package that contains all the necessary, but after run, we have always obtained this error:

```
eclipse.bin: xcb_xlib.c:52: xcb_xlib_unlock: Assertion `c->xlib.lock’ failed
```

To solve this issue is sufficient to insert  this line into *~/.bashrc*:

```
export LIBXCB_ALLOW_SLOPPY_LOCK=1
```

and reload the file:

```
source ~/.bashrc
```

Well, proceed with installation and complete it. At the end a wizard license will be prompt but it was never appear to us, may be because of some problem about the MAC address of our virtual machine (we work under vmware). So, we have prepared a new computer with native Linux, put it out of the net (probably the license evaluation file it will be downloaded directly from Internet during installation), waiting the wizard appear, download the license from CodeSourcery site by hand and import it to the wizard itself.

Only after all these fix and tries we were finally able to work with the new development environment. Unfortunately, using it we have discovered that sometimes Eclipse crashes with no sense and we have not yet understand why.
