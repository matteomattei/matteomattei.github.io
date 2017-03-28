---
title: How to build a web kiosk with Raspberry Pi and make the SD read-only.
description: A step by step guide on how to create a web kiosk system based on Raspberry Pi (1 or 2), Raspbian and make the filesystem safe mouning it in read-only mode.
author: Matteo Mattei
layout: post
permalink: /web-kiosk-with-raspberry-pi-and-read-only-sd/
img_url:
categories:
  - kiosk
  - raspberry
---
Download latest Raspbian Lite distribution (Jessie in my case) from the official [Raspberry website](https://downloads.raspberrypi.org/raspbian_lite_latest).

Then unzip the file and flash the image in the SD card:

```
sudo dd if=2016-02-09-raspbian-jessie-lite.img of=/dev/mmcblk0 bs=1M
```

Power up the RPi2 (or RPi1) with the SD plugged in and log in:

user: **pi**
password: **raspberry**

Now configure the network (wired static ip in my case) editing */etc/dhcpcd.conf* and adding the following lines at the bottom:

```
# my custom static settings
interface eth0
static ip_address=192.168.1.130/24
static routers=192.168.1.254
static domain_name_servers=192.168.1.254
```

Configure Kiosk
-------------------

Execute **raspi-config** to cutomize some settings:

```
sudo raspi-config
```

In particular,

- Set localization (keyboard and system locale)
- Enable SSH
- Expand root partition
- Set autologin on console (B2)

At the end reboot your raspberry pi so that the new filesystem size will take effect.

Login again, update the system and install all needed software:

```
sudo apt-get update
sudo apt-get dist-upgrade
sudo apt-get install midori matchbox-window-manager xserver-xorg x11-xserver-utils unclutter xinit
```

Now add **tty** group to **pi** user because *pi* needs to handle /dev/ttyX devices and adjust permissions accordingly
at every system startup:

```
gpasswd -a pi tty
sed -i '/^exit 0/c\chmod g+rw /dev/tty?\nexit 0' /etc/rc.local
```

Now create a startup script:

```vi /home/pi/startkiosk.sh```

```
#!/bin/bash

# disable DPMS (Energy Star) features.
xset -dpms

# disable screen saver
xset s off

# don't blank the video device
xset s noblank

# disable mouse pointer
unclutter &

# run window manager
matchbox-window-manager -use_cursor no -use_titlebar no  &

# run browser
midori -e Fullscreen -a http://www.google.com
```

and make it executable:

```chmod +x /home/pi/startkiosk.sh```

Then add the following lines at the end of */home/pi/.bashrc*:

```
if [ -z "${SSH_TTY}" ]; then
  xinit ~/startkiosk.sh
fi
```

This three lines allow starting X only when we login as *pi* directly but not from SSH.

Make the SD read-only
--------------------------

Backup your current */etc/fstab* and create a new one with the following content:

```
proc            /proc           proc    defaults          0       0
/dev/mmcblk0p1  /boot           vfat    ro                0       2
/dev/mmcblk0p2  /               ext4    ro                0       1
tmpfs           /tmp            tmpfs   defaults,noatime,mode=1777      0       0
tmpfs           /var/log        tmpfs   defaults,noatime,mode=0755      0       0
tmpfs           /var/lib/systemd tmpfs   defaults,noatime,mode=0755      0       0
tmpfs           /run            tmpfs   defaults,noatime,mode=0755      0       0
```

Then create a little script to help you to change the read-write/read-only mode of the filesystem everytime you need:

```vi /home/pi/mountfs.sh```

```
#!/bin/bash

case "${1}" in
        rw)
                sudo mount -o remount,rw /
                echo "Filesystem mounted in READ-WRITE mode"
                ;;
        ro)
                sudo mount -o remount,ro /
                echo "Filesystem mounted in READ-ONLY mode"
                ;;
        *)
                if [ -n "$(mount | grep mmcblk0p2 | grep -o 'rw')" ]
                then
                        echo "Filesystem is mounted in READ-WRITE mode"
                else
                        echo "Filesystem is mounted in READ-ONLY mode"
                fi
                echo "Usage ${0} [rw|ro]"
                ;;
esac
```

That's it, reboot your RPi and enjoy your *safe* web kiosk!

