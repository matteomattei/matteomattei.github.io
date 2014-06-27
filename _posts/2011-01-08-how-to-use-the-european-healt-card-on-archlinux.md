---
title: How to use the european healt card on Archlinux
author: Matteo Mattei
layout: post
permalink: /how-to-use-the-european-healt-card-on-archlinux/
categories:
  - Linux
tags:
  - Archlinux
  - USB
---
Since some months the regions are sending the new electronic healt card to the house of the people. These cards are featured with a **microchip**. The goal to these cards is the same of the previous ones with in addition the possibility to be read by a smart card reader and store, if you want, your *electronic healt records*. 

This let you enter in your region website and look all your medicines taken, your hospital recovers etc...

So let's start! In this article I will show you how to use this card with the card-reader provided by the Hospital URP with Archlinux and more in general with Linux.

For who does not have the reader, I can suggest to buy the **miniLector bit4id** directly by the URP of the hospital in your zone because its price is fixed (in Italy) to 4,20 Euros instead of fifteen/twenty Euros that is sold elsewhere.

The first thing to do is to connect the bit4id reader to a free USB port of your pc and type **lsusb** in a terminal. You should obtain a line like this:

```
Bus 001 Device 003: ID 072f:90cc Advanced Card Systems, Ltd ACR38 SmartCard Reader
```
Now install the needing packages:

```
pacman -Sy ccid pcsclite pcsc-tools pcsc-perl
yaourt -Sy --aur libminilector38u-bit4id libasecnsp11
```

With root user run *pcsc_scan*, you should obtain a similar output:

```
[root@barracuda ~]# pcsc_scan
PC/SC device scanner
V 1.4.17 (c) 2001-2009, Ludovic Rousseau <ludovic.rousseau@free.fr>
Compiled with PC/SC lite version: 1.6.4
Scanning present readers...
0: ACS ACR 38U-CCID 00 00
Sat Jan  8 17:45:24 2011
  Reader 0: ACS ACR 38U-CCID 00 00
  Card state: Card inserted
  ATR: 3B DF 18 00 81 31 FE 7D 00 6B 15 0C 01 80 01 01 01 43 4E 53 10 31 80 F9
```

At this point you have to configure Firefox for authentication. Proceed in this way:

 1. Make sure the card reader is connected to the PC and the card is inserted
 2. Run Firefox and select *Edit -> Preferences -> Advanced -> Encryption -> Security Devices*
 3. Click on *Load* button and insert *EuropeanHealtCard* as description and */usr/lib/libaseCnsP11.so* as path.
 4. To verify that all works correctly, try to open the link https://servizi.arubapec.it/crtest/showcert.php and insert your PIN.

If the authentication is passed, you should see a welcome message.

Now you only need to access to your electronic health records from your region website using your PIN provided during the card activation.

For a guide on configuring the European Healt card with Ubuntu take a look at Andrea Grandi's [blog](http://www.andreagrandi.it/2010/11/11/utilizzare-la-carta-sanitaria-europea-su-ubuntu-linux/).

For more informations on Linux and the European Healt Card look at [Regione Toscana](http://www.regione.toscana.it/web/guest/guida_linux) website.
