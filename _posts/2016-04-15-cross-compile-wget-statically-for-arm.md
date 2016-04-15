---
title: Cross compile wget statically for ARM
description: A quick how-to on how to compile wget statically for ARM
author: Matteo Mattei
layout: post
permalink: /cross-compile-wget-statically-for-arm/
img_url:
categories:
  - arm 
  - wget
  - compile
---

The following script can be used to statically cross compile **wget** for ARM.

Requirements:

- You need *openssl* and *zlib* already present in the current **$ROOTPATH** directory with related libraries and included respectively inside *libs" and *include* folders.
- You need a *glibc* compiled with `--enable-static-nss` flag so that **getaddrinfo** and **gethostbyname** cannot complain at link time.

{% gist matteomattei/fa5ad16c920e28a7f416b8165edcd84d %}

The resulting binary will be placed into the *build* folder.
