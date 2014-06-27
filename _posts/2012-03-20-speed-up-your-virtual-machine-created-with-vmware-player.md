---
title: Speed-up your virtual machine created with VMware Player
author: Matteo Mattei
layout: post
permalink: /speed-up-your-virtual-machine-created-with-vmware-player/
keywords: "vmware, vmware-player, performance, speed-up, memory, swap"
categories:
  - Virtualization
  - Tricks
  - Vmware
---
![vmware logo](/public/posts_images/vmware_logo.jpg)

If your virtual machine created with VMware Player becomes very slow and takes a long time to complete some operations it's time to improve its performance!
Close your VM, and open the **.vmx* file with a text editor. Then add at the end of the file the following lines:

```
mainMem.useNamedFile = "FALSE"
sched.mem.pshare.enable = "FALSE"
MemTrimRate = 0
MemAllowAutoScaleDown = "FALSE"
prefvmx.useRecommendedLockedMemSize = "TRUE"
prefvmx.minVmMemPct = "100"
```

Make sure to not duplicate the keywords (in case you already have some lines set) otherwise the VM will not start. The above lines totally reserve the memory requested by the VM to the guest system and avoid to continuously ask to the host (and so to the swap file) for new memory chunks.

Try yourself and give me a feedback!
