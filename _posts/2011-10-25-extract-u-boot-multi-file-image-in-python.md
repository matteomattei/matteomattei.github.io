---
title: Extract u-boot multi-file image in Python
description: This is a little snippet of Python code that shows how to extract images from multi-file u-boot image
author: Matteo Mattei
layout: post
permalink: /extract-u-boot-multi-file-image-in-python/
categories:
  - Embedded
  - Linux
  - Python
---
This simple piece of code shows how to extract/decompress a u-boot multi-file image created with *mkimage* using Python. The image format is very simple:

```
64 bytes of image header.
4 bytes for the size of first image.
4 bytes for the size of second image.
...
4 bytes of zeros for termination.
image1.
image2.
...
```

You need to remember also that each image is padded to 4 bytes.

```
#!/usr/bin/env python

import sys

def toNumber(buf):
    """ Convert string in number """
    size = 0
    for b in buf: size=size*256+ord(b)
    return size

if len(sys.argv)!=2:
    sys.stdout.write('Usage %s uboot_image_file\n' % sys.argv[0])
    sys.exit(1)

f = open(sys.argv[1],'rb')
f.seek(64) # skip image header

parts = []

# get file size of all images
while True:
    buf = f.read(4)
    size = toNumber(buf)
    if size==0: break
    parts.append(size)

i = 0
for size in parts:
    pattern = 'file%d.img' % i
    p = open(pattern, 'wb')
    buf = f.read(size)
    p.write(buf)
    p.close()
    if size%4 != 0:
        # 4 byte padding
        f.read(4-(size%4))
    i+=1

f.close()
```
