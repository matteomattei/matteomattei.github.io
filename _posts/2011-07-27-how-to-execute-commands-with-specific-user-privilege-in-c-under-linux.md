---
title: How to execute commands with specific user privilege in C and Python under Linux
description: Two code snippets (in C and Python) to run an executable with a different user/group in Linux
author: Matteo Mattei
layout: post
permalink: /how-to-execute-commands-with-specific-user-privilege-in-c-under-linux/
categories:
  - C/C++
  - Linux
  - Python
---
If you have root access but you need to run some applications/scripts with some other user credentials you can do it with

```
su - username -c "command to execute"
```

But if you need to do it within a C/C++ program you need to write something like this:

```
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <pwd.h>

int main(int argc, char* argv[])
{
    if(argc != 3)
    {
        printf("Usage: %s [USERNAME] [COMMAND]\n",argv[0]);
        return 1;
    }
    char *env[16];
    char envc[16][64];
    struct passwd *pw = getpwnam(argv[1]);
    if(pw==NULL)
    {
        printf("User %s does not exists!\n",argv[1]);
        return 1;
    }

    sprintf(env[0]=envc[0],"TERM=xterm");
    sprintf(env[1]=envc[1],"USER=%s",pw->pw_name);
    sprintf(env[2]=envc[2],"HOME=%s",pw->pw_dir);
    sprintf(env[3]=envc[3],"SHELL=%s",pw->pw_shell);
    sprintf(env[4]=envc[4],"LOGNAME=%s",pw->pw_name);
    sprintf(env[5]=envc[5],"PATH=/usr/bin:/bin:/opt/bin");
    env[6]=0;

    initgroups(argv[1],pw->pw_gid);
    setgid(pw->pw_gid);
    setuid(pw->pw_uid);
    execve(argv[2],NULL,env);

    return 0;
}
```

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

```
#!/usr/bin/env python

import sys,pwd,os

pw = pwd.getpwnam(sys.argv[1])
os.initgroups(sys.argv[1],pw.pw_gid)
env={"TERM":"xterm","USER":pw.pw_name,"HOME":pw.pw_dir,"SHELL":pw.pw_shell,"LOGNAME":pw.pw_name,"PATH":"/usr/bin:/bin:/opt/bin"};
os.setgid(pw.pw_gid);
os.setuid(pw.pw_uid);
os.execve(sys.argv[2],[],env);
```
