---
title: How to shrink raspberry pi backup images
description: A guide on how to reduce the size of raspberry pi backup images
author: Matteo Mattei
layout: post
permalink: /how-to-shrink-raspberry-pi-backup-images/
img_url:
categories:
  - raspberrypi
  - backup
---

When I backup my raspberry pi SD card one problem I always faced is how much storage space I have to use because using *dd* command the resulting backup image is exactly the same size of the whole SD card and having memory cards of 32GB or more, the storage of my pc would end pretty soon.

That said I wrote a little script that takes the *big* image, resize it to the minimal and compress it using gzip.

Just for completeness, this is the command I use to create the image of the SD card:

```
sudo dd if=/dev/mmcblk0 of=/path/to/image.img bs=1M
```

Now you can use the following script to shrink the image:

```
sudo ./raspberrypi_image_resize.sh /path/to/image.img
```

{% gist matteomattei/86e06f24808f7c549b615935fb178a5d %}

The process takes some time and at the end you will find that the size of the compressed image is drastically reduced. This is an example of a 8GB SD card before and after the compression:

```
-rw-r--r-- 1 matteo matteo 8026849280 Sep 10 15:45 image.img
-rw-r--r-- 1 matteo matteo  468097056 Sep 12 12:57 image.img.gz
```

So from a 8GB file, we have obtained 460MB file.