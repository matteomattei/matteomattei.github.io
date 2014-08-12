---
title: How to use SysBench on Debian, CentOS and Ubuntu 
description: This article explains the installation and usage of sysbench Linux tool across Debian, CentOS and Ubuntu to test the performance of a cloud server I have to purchase.
author: Matteo Mattei
layout: post
permalink: /how-to-sysbench-on-debian-centos-ubuntu/
categories:
  - cloudatcost.com
  - sysbench
  - benchmark
  - performance
---

Sysbench tutorial
=================

I need to test the performance of [cloudatcost](http://www.cloudatcost.com) before deciding to purchase a *big dog 3* server. Fortunately a guy gave me access to his Big Dog 3 server for 24 hours so that I can test it before buying. So I decided to compare stats between my laptop, the chepest cloudatcost plan that I previously purchased and the Big Dog 3 plan.


My Laptop:
----------

Configuration:
```
Distribution: Ubuntu 14.04 @ 64 bit
RAM: 8GB
HD: 750 GB hybrid (8GB SSD)
CPU: Intel(R) Core(TM) i7-2670QM CPU @ 2.20GHz (8 core)
```

 1. Install sysbench:

    ```
    matteo@margot:~$ sudo apt-get install sysbench
    matteo@margot:~$ sysbench --version
    sysbench 0.4.12
    ```

 2. CPU benchmark:

    ```
    matteo@margot:~$ sudo sysbench --test=cpu --cpu-max-prime=20000 run
    sysbench 0.4.12:  multi-threaded system evaluation benchmark
    
    Running the test with following options:
    Number of threads: 1
    
    Doing CPU performance benchmark
    
    Threads started!
    Done.
    
    Maximum prime number checked in CPU test: 20000
    
    
    Test execution summary:
        total time:                          28.1221s
        total number of events:              10000
        total time taken by event execution: 28.1210
        per-request statistics:
             min:                                  2.76ms
             avg:                                  2.81ms
             max:                                 10.89ms
             approx.  95 percentile:               2.88ms
    
    Threads fairness:
        events (avg/stddev):           10000.0000/0.00
        execution time (avg/stddev):   28.1210/0.00
    ```

 3. I/O benchmark:

    ```
    matteo@margot:~$ sysbench --test=fileio --file-total-size=15G prepare
    sysbench 0.4.12:  multi-threaded system evaluation benchmark
    
    128 files, 122880Kb each, 15360Mb total
    Creating files for the test...
    matteo@margot:~$ sysbench --test=fileio --file-total-size=15G --file-test-mode=rndrw --init-rng=on --max-time=300 --max-requests=0 run
    sysbench 0.4.12:  multi-threaded system evaluation benchmark
    
    Running the test with following options:
    Number of threads: 1
    Initializing random number generator from timer.
    
    
    Extra file open flags: 0
    128 files, 120Mb each
    15Gb total file size
    Block size 16Kb
    Number of random requests for random IO: 0
    Read/Write ratio for combined random IO test: 1.50
    Periodic FSYNC enabled, calling fsync() each 100 requests.
    Calling fsync() at the end of test, Enabled.
    Using synchronous I/O mode
    Doing random r/w test
    Threads started!
    Time limit exceeded, exiting...
    Done.
    
    Operations performed:  12720 Read, 8480 Write, 27014 Other = 48214 Total
    Read 198.75Mb  Written 132.5Mb  Total transferred 331.25Mb  (1.1041Mb/sec)
       70.66 Requests/sec executed
    
    Test execution summary:
        total time:                          300.0118s
        total number of events:              21200
        total time taken by event execution: 158.6743
        per-request statistics:
             min:                                  0.00ms
             avg:                                  7.48ms
             max:                                 68.36ms
             approx.  95 percentile:              26.58ms
    
    Threads fairness:
        events (avg/stddev):           21200.0000/0.00
        execution time (avg/stddev):   158.6743/0.00
    
    matteo@margot:~$ sudo sysbench --test=fileio --file-total-size=15G cleanup
    [sudo] password for matteo: 
    sysbench 0.4.12:  multi-threaded system evaluation benchmark
    
    Removing test files...
    ```

cloudatcost.com - Developer 1 plan:
-----------------------------------
Configuration:
```
Distribution: Debian 7.6 @ 64 bit
RAM: 512MB ECC
CPU: 1 Xeon vCPU
HD: 10GB SSD
```

 1. Install sysbench:

    ```
    root@debian:~# apt-get install sysbench
    root@debian:~# sysbench --version
    sysbench 0.4.12
    ```
    
 2. CPU benchmark:

    ```
    root@debian:~# sysbench --test=cpu --cpu-max-prime=20000 run
    sysbench 0.4.12:  multi-threaded system evaluation benchmark
    
    Running the test with following options:
    Number of threads: 1
    
    Doing CPU performance benchmark
    
    Threads started!
    Done.
    
    Maximum prime number checked in CPU test: 20000
    
    
    Test execution summary:
        total time:                          29.8126s
        total number of events:              10000
        total time taken by event execution: 29.8099
        per-request statistics:
             min:                                  2.93ms
             avg:                                  2.98ms
             max:                                  5.08ms
             approx.  95 percentile:               3.04ms
    
    Threads fairness:
        events (avg/stddev):           10000.0000/0.00
        execution time (avg/stddev):   29.8099/0.00
    ```
    
 3. I/O benchmark:

    ```
    root@debian:~# sysbench --test=fileio --file-total-size=5G prepare
    sysbench 0.4.12:  multi-threaded system evaluation benchmark
    
    128 files, 40960Kb each, 5120Mb total
    Creating files for the test...
    root@debian:~# sysbench --test=fileio --file-total-size=5G --file-test-mode=rndrw --init-rng=on --max-time=300 --max-requests=0 run
    sysbench 0.4.12:  multi-threaded system evaluation benchmark
    
    Running the test with following options:
    Number of threads: 1
    Initializing random number generator from timer.
    
    
    Extra file open flags: 0
    128 files, 40Mb each
    5Gb total file size
    Block size 16Kb
    Number of random requests for random IO: 0
    Read/Write ratio for combined random IO test: 1.50
    Periodic FSYNC enabled, calling fsync() each 100 requests.
    Calling fsync() at the end of test, Enabled.
    Using synchronous I/O mode
    Doing random r/w test
    Threads started!
    Time limit exceeded, exiting...
    Done.
    
    Operations performed:  38731 Read, 25820 Write, 82560 Other = 147111 Total
    Read 605.17Mb  Written 403.44Mb  Total transferred 1008.6Mb  (3.3386Mb/sec)
      213.67 Requests/sec executed
    
    Test execution summary:
        total time:                          302.1012s
        total number of events:              64551
        total time taken by event execution: 180.8488
        per-request statistics:
             min:                                  0.00ms
             avg:                                  2.80ms
             max:                               3856.24ms
             approx.  95 percentile:               1.28ms
    
    Threads fairness:
        events (avg/stddev):           64551.0000/0.00
        execution time (avg/stddev):   180.8488/0.00
    
    root@debian:~# sysbench --test=fileio --file-total-size=5G cleanup
    sysbench 0.4.12:  multi-threaded system evaluation benchmark
    
    Removing test files...
    ```

cloudatcost.com - Big Dog 3 plan:
---------------------------------
Configuration:
```
Distribution: CentOS 6.5 @ 64 bit
RAM: 8GB ECC
CPU: 8 Xeon vCPU
HD: 80GB SSD
```

 1. Install sysbench:

    ```
    root@localhost [~]# wget http://www.lefred.be/files/sysbench-0.5-3.el6_.x86_64.rpm
    root@localhost [~]# rpm -ivh sysbench-0.5-3.el6_.x86_64.rpm 
    root@localhost [~]# sysbench --version
    sysbench 0.5
    ```

 2. CPU benchmark:

    ```
    root@localhost [~]# sysbench --test=cpu --cpu-max-prime=20000 run
    sysbench 0.5:  multi-threaded system evaluation benchmark
    
    Running the test with following options:
    Number of threads: 1
    Random number generator seed is 0 and will be ignored
    
    
    Primer numbers limit: 20000
    
    Threads started!
    
    
    General statistics:
        total time:                          31.0954s
        total number of events:              10000
        total time taken by event execution: 31.0830s
        response time:
             min:                                  3.07ms
             avg:                                  3.11ms
             max:                                  5.86ms
             approx.  95 percentile:               3.17ms
    
    Threads fairness:
        events (avg/stddev):           10000.0000/0.00
        execution time (avg/stddev):   31.0830/0.00
    ```

 3. I/O benchmark:

    ```
    root@localhost [~]# sysbench --test=fileio --file-total-size=15G prepare
    sysbench 0.5:  multi-threaded system evaluation benchmark
    
    128 files, 122880Kb each, 15360Mb total
    Creating files for the test...
    Extra file open flags: 0
    Creating file test_file.0
    Creating file test_file.1
    Creating file test_file.2
    Creating file test_file.3
    Creating file test_file.4
    Creating file test_file.5
    Creating file test_file.6
    Creating file test_file.7
    Creating file test_file.8
    Creating file test_file.9
    Creating file test_file.10
    Creating file test_file.11
    Creating file test_file.12
    Creating file test_file.13
    Creating file test_file.14
    Creating file test_file.15
    Creating file test_file.16
    Creating file test_file.17
    Creating file test_file.18
    Creating file test_file.19
    Creating file test_file.20
    Creating file test_file.21
    Creating file test_file.22
    Creating file test_file.23
    Creating file test_file.24
    Creating file test_file.25
    Creating file test_file.26
    Creating file test_file.27
    Creating file test_file.28
    Creating file test_file.29
    Creating file test_file.30
    Creating file test_file.31
    Creating file test_file.32
    Creating file test_file.33
    Creating file test_file.34
    Creating file test_file.35
    Creating file test_file.36
    Creating file test_file.37
    Creating file test_file.38
    Creating file test_file.39
    Creating file test_file.40
    Creating file test_file.41
    Creating file test_file.42
    Creating file test_file.43
    Creating file test_file.44
    Creating file test_file.45
    Creating file test_file.46
    Creating file test_file.47
    Creating file test_file.48
    Creating file test_file.49
    Creating file test_file.50
    Creating file test_file.51
    Creating file test_file.52
    Creating file test_file.53
    Creating file test_file.54
    Creating file test_file.55
    Creating file test_file.56
    Creating file test_file.57
    Creating file test_file.58
    Creating file test_file.59
    Creating file test_file.60
    Creating file test_file.61
    Creating file test_file.62
    Creating file test_file.63
    Creating file test_file.64
    Creating file test_file.65
    Creating file test_file.66
    Creating file test_file.67
    Creating file test_file.68
    Creating file test_file.69
    Creating file test_file.70
    Creating file test_file.71
    Creating file test_file.72
    Creating file test_file.73
    Creating file test_file.74
    Creating file test_file.75
    Creating file test_file.76
    Creating file test_file.77
    Creating file test_file.78
    Creating file test_file.79
    Creating file test_file.80
    Creating file test_file.81
    Creating file test_file.82
    Creating file test_file.83
    Creating file test_file.84
    Creating file test_file.85
    Creating file test_file.86
    Creating file test_file.87
    Creating file test_file.88
    Creating file test_file.89
    Creating file test_file.90
    Creating file test_file.91
    Creating file test_file.92
    Creating file test_file.93
    Creating file test_file.94
    Creating file test_file.95
    Creating file test_file.96
    Creating file test_file.97
    Creating file test_file.98
    Creating file test_file.99
    Creating file test_file.100
    Creating file test_file.101
    Creating file test_file.102
    Creating file test_file.103
    Creating file test_file.104
    Creating file test_file.105
    Creating file test_file.106
    Creating file test_file.107
    Creating file test_file.108
    Creating file test_file.109
    Creating file test_file.110
    Creating file test_file.111
    Creating file test_file.112
    Creating file test_file.113
    Creating file test_file.114
    Creating file test_file.115
    Creating file test_file.116
    Creating file test_file.117
    Creating file test_file.118
    Creating file test_file.119
    Creating file test_file.120
    Creating file test_file.121
    Creating file test_file.122
    Creating file test_file.123
    Creating file test_file.124
    Creating file test_file.125
    Creating file test_file.126
    Creating file test_file.127
    16106127360 bytes written in 1661.93 seconds (9.24 MB/sec).
    
    root@localhost [~]# sysbench --test=fileio --file-total-size=15G --file-test-mode=rndrw --init-rng=on --max-time=300 --max-requests=0 run
    sysbench 0.5:  multi-threaded system evaluation benchmark
    
    Running the test with following options:
    Number of threads: 1
    Random number generator seed is 0 and will be ignored
    
    
    Extra file open flags: 0
    128 files, 120Mb each
    15Gb total file size
    Block size 16Kb
    Number of IO requests: 0
    Read/Write ratio for combined random IO test: 1.50
    Periodic FSYNC enabled, calling fsync() each 100 requests.
    Calling fsync() at the end of test, Enabled.
    Using synchronous I/O mode
    Doing random r/w test
    Threads started!
    
    Operations performed:  45662 reads, 30441 writes, 97408 Other = 173511 Total
    Read 713.47Mb  Written 475.64Mb  Total transferred 1.1612Gb  (3.9637Mb/sec)
      253.68 Requests/sec executed
    
    General statistics:
        total time:                          300.0017s
        total number of events:              76103
        total time taken by event execution: 31.1080s
        response time:
             min:                                  0.00ms
             avg:                                  0.41ms
             max:                                 65.85ms
             approx.  95 percentile:               2.54ms
    
    Threads fairness:
        events (avg/stddev):           76103.0000/0.00
        execution time (avg/stddev):   31.1080/0.00
    
    root@localhost [~]# sysbench --test=fileio --file-total-size=15G cleanup
    sysbench 0.5:  multi-threaded system evaluation benchmark
    
    Removing test files...
    ```

Network benchmark:
------------------

In order to test also the Network performance I use the [speedtest-cli](https://github.com/sivel/speedtest-cli) tool. But I do this test only in the Big Dog 3 server.

```
root@localhost [~]# wget -q -O - https://raw.github.com/sivel/speedtest-cli/master/speedtest_cli.py | python
Retrieving speedtest.net configuration...
Retrieving speedtest.net server list...
Testing from KW Datacenter (167.88.44.169)...
Selecting best server based on latency...
Hosted by Source Cable Ltd (Hamilton, ON) [52.90 km]: 22.833 ms
Testing download speed........................................
Download: 236.30 Mbits/s
Testing upload speed..................................................
Upload: 148.09 Mbits/s
```

Conclusions:
------------

I finally decided to purchase a *Big Dog 2* plan from [CloudAtCost](http://www.cloudatcost.com) and as far as I experimented the performance is not so bad (for the moment)... The only problem I see is that sometimes the network seems missing some packets as long as some sporatic stucks of 2/3 seconds when accessing the filesystem from a SSH connection.
