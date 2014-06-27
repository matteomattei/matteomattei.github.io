---
title: OpenSuse 10.3 CD and DVD with fault installer? Reinstalling the bootloader!
author: Matteo Mattei
layout: post
permalink: /opensuse-10-3-cd-and-dvd-with-fault-installer-reinstall-the-bootloade/
screenshot1:
  - 
categories:
  - Linux
tags:
  - grub
  - OpenSuse
---
Today I tested the new OpenSuse 10.3 with KDE both in CD and DVD version on an old Packard Bell Desk Pro. After a long wait during installation, at automatic reboot it will be prompt a classic black screen with the message "*Operative System not present*". After a vanished search on the net looking for some informations, I thought that the installer was failed to install the bootloader and so I have just tried to do it manually. Here there are all the steps I follow:

 - Boot OpenSuse installation CD/DVD and enter in **Recovery** mode
 - Run grub ed enter in its own shell
 - From here run these commands:

```
grub> root (hd0,1)
grub> setup (hd0)
grub> quit
```
    
Where:  
 - **hd0,1 => sda2**  
 - **hd0 => sda** </li> 

Restart the system and magically the installation will go on.