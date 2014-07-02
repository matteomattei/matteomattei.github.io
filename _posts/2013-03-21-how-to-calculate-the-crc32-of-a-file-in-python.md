---
title: How to calculate the crc32 of a file in Python
description: A simple Python snippet of code that shows how to calculate crc32 of a file
author: Matteo Mattei
layout: post
permalink: /how-to-calculate-the-crc32-of-a-file-in-python/
categories:
  - Python
  - Algorithms
---
Calculating the crc32 of a file in Python is very simple but I often forgot how to do. For this reason I put this snippet here:

```
#!/usr/bin/env python

import binascii

def CRC32_from_file(filename):
    buf = open(filename,'rb').read()
    buf = (binascii.crc32(buf) & 0xFFFFFFFF)
    return "%08X" % buf
```

You can simply call the *CRC32_from_file()* function passing a file with the whole path as argument.
