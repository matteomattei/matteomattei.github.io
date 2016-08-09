---
title: Enable SSH authentication using RSA key-pair without password
description: A little guide on how to enable ssh authentication without password using RSA key pair.
author: Matteo Mattei
layout: post
permalink: /enable-ssh-authentication-without-password-using-rsa-keypair/
img_url:
categories:
  - server
  - ssh
  - cryptography
  - security
---

If you have to manage multiple servers, if you want to enforce the security of your servers, if you want to run remote script using SSH in crontab, or simply if you don't want to remember the SSH password everytime, this is the guide for you!

First of all you need to generate a RSA keypair in your PC/Mac:

```
ssh-keygen -t rsa -b 2048 -C "your-email@example.com" -f ~/.ssh/id_rsa
```

 - **-t** is the type of algorithm to use (RSA)
 - **-b** is the length of the key to generate (2048 is sufficient)
 - **-C** is the comment/identification of the key (you can use your email address)
 - **-f** is the path of the private key to generate (the public will be stored in the same folder with *.pub* suffix)

When you are asked for a passphrase just press *Enter* to not input any passphrase.
At the end a couple of keys will be stored in *~/.ssh* folder with the correct permissions and they will be called respectively **id_rsa** (the private key) and **id_rsa.pub** (the public key).

In case you are copying the keys from somehow to your *~/.ssh* folder make sure the permissions are correct:

```
-rw-------  1 matteo matteo  1679 Aug 15  2015 id_rsa
-rw-r--r--  1 matteo matteo   398 Aug 15  2015 id_rsa.pub
```

Now from your PC/Mac copy the private key to the remote server:

```
ssh-copy-id remoteuser@remoteserver-ip
```

This time you will need to provide the password because the remote server is still not aware of your key. Even if the best approach is the this, the same operation could also be done manually using *scp*:

```
scp ~/.ssh/id_rsa.pub remoteuser@remoteserver-ip:/tmp/
[ENTER IN THE REMOTE SERVER]
ssh remoteuser@remoteserver-ip
mkdir ~/.ssh
cat /tmp/id_rsa.pub >> ~/.ssh/authorized_keys
rm /tmp/id_rsa.pub
exit
```

Now try to connect to the remote server via SSH:

```
ssh remoteuser@remoteserver-ip
```

If all goes well, the password should not be asked and you can access to the server directly.
But it is not finished... now we want to block the password authentication for all users and allow root login, so login to the server as root and change */etc/ssh/sshd_config* in this way:

```
PermitRootLogin without-password
RSAAuthentication yes
PubkeyAuthentication yes
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM no
```

Restart ssh daemon (**/etc/init.d/ssh restart**) and from another shell try to connect again.
You should be able to access to the server without enterning any password. I suggest to use another shell because if something went wrong you can always recover the issue using the first shell.

Remember to copy the public key in the *authorized_keys* file of every remote user that can accept remote connections via ssh.