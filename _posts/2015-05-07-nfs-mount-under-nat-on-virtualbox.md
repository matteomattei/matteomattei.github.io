---
title: Mount NFS share using Virtualbox under NAT
description: Mounting NFS share on Virtualbox with the ethernet interface in NAT might be painful. This article explains how to do it.
author: Matteo Mattei
layout: post
permalink: /nfs-mount-under-nat-on-virtualbox/
img_url:
categories:
  - nfs
  - virtualbox
  - nat
---
I am using Ubuntu 14.04 (but it is valid also with other Linux distributions) that runs under Virtualbox. My network interface is set as **NAT** and I am running nfs version 4 (NFSv4).

Every time I try to mount a remote share I always obtain the following error:

```
matteo@vm:~$ sudo mount -t nfs xxx.xxx.xxx.xxx:/opt/share /mnt/remote
mount.nfs: access denied by server while mounting xxx.xxx.xxx.xxx:/opt/share
```

And in the kernel log (dmesg) I see this:

```
[ 1351.443078] RPC: server xxx.xxx.xxx.xxx requires stronger authentication.
```

The issue here is that the NFS client is trying to use UDP protocol to access the remote host. You can verify it by capturing the network traffic with wireshark (or tcpdump).
In this case is sufficient to force the usage of the TCP protocol when you mount the share:

```
matteo@vm:~$ sudo mount -t nfs xxx.xxx.xxx.xxx:/opt/share /mnt/remote -o proto=tcp
matteo@vm:~$
```

Another option is to change your network adapter in Virtualbox from **NAT** to **BRIDGE**.

That's all for the moment.
