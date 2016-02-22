---
title: Share internet connection to the the LAN, protect everything with a firewall and setup dhcp server on Linux.
description: A quick how-to on how to configure Shorewall with two interfaces to share internet to the LAN, protect clients with a firewall and setup dhcp server to assign automatic ip addresses.
author: Matteo Mattei
layout: post
permalink: /share-internet-connection-to-the-lan-with-dhcp-server/
img_url:
categories:
  - server
  - networking
  - firewall
  - shorewall
  - dnsmasq
---


I have a router with a public static ip address provided by the ISP and I need to share internet access to all pc in the LAN. To do it I need a server with two ethernet interfaces (eth0 and eth1) that will act as a firewall and dhcp server. That server will also be used as a web server to publish some contents in the LAN and in internet.

My configuration is this:

- **eth0** with **public static IP address** provided by the ISP.
- **eth1** with **private static IP address** assigned by me and connected to a switch.

Install shorewall:

```
apt-get install shorewall
```

Start configuration with two interface shorewall example:

```
cd /usr/share/doc/shorewall/examples/two-interfaces/
cp interfaces /etc/shorewall/
cp masq /etc/shorewall/
cp policy /etc/shorewall/
cp rules /etc/shorewall/
cp zones /etc/shorewall/
cp stoppedrules /etc/shorewall/
```

Now configure */etc/network/interfaces* (I am using Debian jessie):

```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address xxx.xxx.xxx.xxx
netmask yyy.yyy.yyy.yyy
gateway zzz.zzz.zzz.zzz

auto eth1
iface eth1 inet static
address 192.168.0.1
netmask 255.255.255.0
```

where:

- **xxx.xxx.xxx.xxx** is the public IP address provided by the ISP
- **yyy.yyy.yyy.yyy** is the netmask provided by the ISP
- **zzz.zzz.zzz.zzz** is the gateway provided by the ISP

And */etc/resolv.conf*:

```
# Google DNS
nameserver 8.8.8.8
nameserver 8.8.4.4
```

Now configure shorewall to act as firewall and share internet to all LAN devices.

File: `/etc/shorewall/interfaces`

```
#ZONE   INTERFACE       OPTIONS
net     eth0            dhcp,tcpflags,nosmurfs,routefilter,logmartians,sourceroute=0
loc     eth1            dhcp,tcpflags,nosmurfs,routefilter,logmartians
```

File: `/etc/shorewall/zones`

```
#ZONE   TYPE    OPTIONS                 IN                      OUT
#                                       OPTIONS                 OPTIONS
fw      firewall
net     ipv4
loc     ipv4
```

File: `/etc/shorewall/policy`

```
#SOURCE         DEST            POLICY          LOG LEVEL       LIMIT:BURST

$FW             net             ACCEPT
$FW             loc             ACCEPT
loc             net             ACCEPT
net             all             DROP            info
# THE FOLLOWING POLICY MUST BE LAST
all             all             REJECT          info
```

File: `/etc/shorewall/rules`

```
?SECTION ALL
?SECTION ESTABLISHED
?SECTION RELATED
?SECTION INVALID
?SECTION UNTRACKED
?SECTION NEW

#       Don't allow connection pickup from the net
#
Invalid(DROP)   net             all             tcp
#
#       Accept DNS connections from the firewall to the network
#
DNS(ACCEPT)     $FW             net
DNS(ACCEPT)     loc             $FW
#
#       Accept SSH connections from the local network for administration
#
SSH(ACCEPT)     loc             $FW
#
#       Allow Ping from the local network
#
Ping(ACCEPT)    loc             $FW

#
# Drop Ping from the "bad" net zone.. and prevent your log from being flooded..
#

Ping(DROP)      net             $FW

ACCEPT          $FW             loc             icmp
ACCEPT          $FW             net             icmp
#

# custom rules
SSH(ACCEPT)     net             $FW
Web(ACCEPT)     net             $FW
Web(ACCEPT)     loc             $FW

# DNAT rules (useful for natting a service on a device)
# this rule opens port 8080 from internet to port 80 of 192.168.0.2 in TCP
# ACCEPT                net             192.168.0.2:80  tcp     8080
```

The above configuration allows SSH connections from local and from remote as well as Web access.

File: `/etc/shorewall/masq`

```
#INTERFACE:DEST         SOURCE          ADDRESS         PROTO   PORT(S) IPSEC   MARK    USER/   SWITCH  ORIGINAL
#                                                                                       GROUP           DEST
eth0                    eth1
```

File: `/etc/shorewall/stoppedrules`

```
#ACTION         SOURCE          DEST            PROTO   DEST            SOURCE
#                                                       PORT(S)         PORT(S)
ACCEPT          eth1            -
ACCEPT          -               eth1
```

Now edit `/etc/shorewall/shorewall.conf` and set:

```
STARTUP_ENABLED=Yes
IP_FORWARDING=On
```

In particular the last line is necessary to share internet to the LAN.
Edit now `/etc/default/shorewall` and set:

```
startup=1
```

Now start shorewall:

```
/etc/init.d/shorewall start
```

And try to configure a pc in the LAN with a static ip address, for example:

```
address: 192.168.0.200
netmask: 255.255.255.0
gateway: 192.168.0.1
```

Yeah, the pc should be able to access internet!
But we need to go a little bit ahead because given we don't want to assign a static ip address to all pc (or devices) in the LAN. So we have to install a DHCP server.

```
apt-get install dnsmasq
```

Now backup the default configuration of dnsmasq and create a new `/etc/dnsmasq.conf` with something like this:

```
interface=eth1
dhcp-range=192.168.0.50,192.168.0.150,12h
dhcp-host=60:E3:27:8D:88:64,accesspoint,192.168.0.10
dhcp-host=F8:32:E5:84:3A:1F,pc1,192.168.0.11
dhcp-host=F8:32:E5:84:2D:71,pc2,192.168.0.12
dhcp-host=F8:32:E5:84:2D:B6,pc3,192.168.0.13
```

The first line specifies the **interface** where the DHCP server is running (eth1 for me1).
The second line (**dhcp-range**) is the range of IP addresses that the DHCP server will provide with a lease of 12 hours. In this case from address 192.168.0.50 to address 192.168.0.150.
All other lines are used to define devices with static IPs. The syntax is:

`dhcp-host=DEVICE_MAC_ADDRESS,DEVICE_NAME,DEVICE_IP`

Dnsmasq beyond dhcp and DNS caching provides also another interesting feature... every entry you set in */etc/hosts* of the server is automatically forwarded to all devices in the LAN. This means that if we want to set a simple name for accessing the webserver from the LAN it's just a matter of editing /etc/hosts and add the server's name:

```
127.0.0.1       localhost
192.168.0.1     myserver
```

This allows all devices in the LAN to access the server using `myserver`.

Now restart dnsmasq:

```
/etc/init.d/dnsmasq restart
```

To list all devices that have received a new IP address the file to look at is `/var/lib/misc/dnsmasq.leases`

Resources:
-----------------
- [Official shorewall documentation](http://shorewall.net/two-interface.htm)
- [dnsmasq howto](https://wiki.archlinux.org/index.php/Dnsmasq)

