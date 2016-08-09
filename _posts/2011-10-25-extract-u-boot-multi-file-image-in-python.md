---
title: Extract u-boot multi-file image in Python
description: This is a little snippet of Python code that shows how to extract images from multi-file u-boot image
author: Matteo Mattei
layout: post
permalink: /extract-u-boot-multi-file-image-in-python/
categories:
  - embedded
  - linux
  - python
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

{% gist matteomattei/9e6c8f123e39c620dcd4 %}
