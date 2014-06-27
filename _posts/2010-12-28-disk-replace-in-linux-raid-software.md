---
title: Disk replace in Linux raid software
author: Matteo Mattei
layout: post
permalink: /disk-replace-in-linux-raid-software/
categories:
  - Bash
  - Linux
tags:
  - RAID
---
Sometimes it happens that, after a long time of usage, one disk is going to be damage and starts to give some troubles... What's happened when the disk is part of a software raid? If the failing disk is only one, all data are safe but you have to replace the disk as soon as possible in order to avoid very ugly surprises! I know that is always a very frustrating thing to change a disk from a raid software.

However, when a disk in RAID 5 or in RIAD 1 should be replaced, you have to follow these steps:

 1.  Take a look at */proc/mdstat*, if is all ok (i.e. you have to replace a disk that contains some corrupted sectors but the raid is yet integer) mark the bad partition as failed (sdb1 in my case), otherwise continue from step 2:

    ```mdadm --manage /dev/md0 --fail /dev/sdb1```

 2.  Remove that partition from the Raid array:
    ```mdadm --manage /dev/md0 --remove /dev/sdb1```

 3.  Shutdown the pc, change the disk and power on the pc again.
 4.  At this point if you type ```cat /proc/mdstat``` you should see **[U_U]**. 
 5. Copy now the partition table from a working disk (sda) to the new inserted disk (sdb):
    ```sfdisk -d /dev/sda | sfdisk /dev/sdb```
 6. Add the new partition to the array:
    ```mdadm --manage /dev/md0 --add /dev/sdb1```
 7. Done!
    
When you have finished, type
```
cat /proc/mdstat
```
and wait for the array rebuild.

At the end of the process (that can takes also some hours, depending on the size of the partition) you should have all "U" (**[UUU]**).
