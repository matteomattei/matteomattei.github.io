---
title: How to execute commands with specific user privilege in C and Python under Linux
description: Two code snippets (in C and Python) to run an executable with a different user/group in Linux
author: Matteo Mattei
layout: post
permalink: /how-to-execute-commands-with-specific-user-privilege-in-c-under-linux/
categories:
  - c/c++
  - linux
  - python
---
If you have root access but you need to run some applications/scripts with some other user credentials you can do it with

```
su - username -c "command to execute"
```

But if you need to do it within a C/C++ program you need to write something like this:

{% gist matteomattei/8ed2e80502dcd12bb65e %}

This is how to compile and execute the above code:

```
[root@barracuda ~]# gcc mysu.c -o mysu
[root@barracuda ~]# id
uid=0(root) gid=0(root) gruppi=0(root),1(bin),2(daemon),3(sys),4(adm),6(disk),10(wheel),19(log)
[root@barracuda ~]# ./mysu matteo /bin/bash
[matteo@barracuda /root]$ id
uid=1000(matteo) gid=100(users) groups=100(users),3(sys),10(wheel),14(uucp),91(video),92(audio),93(optical),95(storage),96(scanner),97(camera),98(power),108(vboxusers)
```

The same result could be obtained also in Python with a very little effort:

{% gist matteomattei/737c8f9797e0c2f5eb36 %}
