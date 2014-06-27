---
title: How to implement MAC_X919 algorithm in Python
author: Matteo Mattei
layout: post
permalink: /how-to-implement-mac_x919-algorithm-in-python/
categories:
  - Python
---
Today with my friend Nicola, we were looking in Internet for the implementation of the **X9.19 algorithm** in Python. Unfortunately we didn't find it anywhere, so we made it ourself:

```
#!/usr/bin/env python2

import Crypto.Cipher.DES as des
import Crypto.Cipher.DES3 as des3

def mac_x919(key,data):
  while len(data) % 8 != 0:
    data += '\x00'
  des_key1 = des.new(key[0:8],des.MODE_CBC)
  des_key2 = des.new(key[0:8],des.MODE_ECB)
  buf = des_key1.encrypt(data)
  buf = buf[len(buf)-8:]
  buf = des_key2.decrypt(buf)
  des3_key = des3.new(key,des3.MODE_ECB)
  buf = des3_key.encrypt(buf)
  return buf[0:4]

mac = mac_x919('0123456789abcdef','test data to be encrypted')
```
