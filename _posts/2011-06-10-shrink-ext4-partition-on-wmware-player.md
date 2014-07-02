---
title: Shrink Ext4 partition on VMware player
description: A guide for shrinking VMware images that have EXT4 partitions
author: Matteo Mattei
layout: post
permalink: /shrink-ext4-partition-on-wmware-player/
categories:
  - Linux
  - Vmware
---
![VMWARE](/public/posts_images/vmware_logo.jpg)
Few days ago I spent some times trying to shrink my Ubuntu 11.04 appliance with root partition formatted with *EXT4* filesystem.

The main problem is that the current VMware tools (8.4.6, build-385536) does not support the ext4 shrink. If you run ```sudo vmware-toolbox```, your root partition is formatted in ext4 and you try to execute the shrink, an error message like the following could appear.

![VMWARE SHRINK ERROR](/public/posts_images/vmware_shrink_error.jpg)

Anyway there is a trick to streamline the final *vmdk* size.  
Run this command within a shell into the guest system:

```
sudo dd if=/dev/zero of=/zero.raw bs=20480
rm -f /zero.raw
```

Then, shutdown the virtual image and download the **vdiskmanager** tool from [VMware website](http://communities.vmware.com/community/vmtn/developer/forums/vddk).  

Now run the *vmware-vdiskmanager* with the *-k* parameter:

```
vmware-diskmanager -k /path/to/image.vmdk
```

This operation will take a while, but at the end you will get a considerable smaller vmdk image file.
