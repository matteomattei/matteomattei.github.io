---
title: How to calculate the crc32 of a file in Python
description: A simple Python snippet of code that shows how to calculate crc32 of a file
author: Matteo Mattei
layout: post
permalink: /how-to-calculate-the-crc32-of-a-file-in-python/
categories:
  - python
  - algorithms
---
Calculating the crc32 of a file in Python is very simple but I often forgot how to do. For this reason I put this snippet here:

{% gist matteomattei/160c1198682e92f6f2a0 %}

You can simply call the *CRC32_from_file()* function passing a file with the whole path as argument.
