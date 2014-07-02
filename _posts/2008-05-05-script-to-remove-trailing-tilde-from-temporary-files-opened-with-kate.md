---
title: Script to remove trailing tilde (~) from temporary files
description: A simple bash script that shows how to remove trailing tildes (~) from generated temporary files
author: Matteo Mattei
layout: post
permalink: /script-to-remove-trailing-tilde-from-temporary-files/
categories:
  - bash
  - linux
  - tricks
---
Using kate as similar text editors, temporary files that have been saved present an annoying trailing tilde that I personally consider useless. I am used to be careful when I edit a file, so I don't need the *backups*. For this reason I developed this mini script in bash to remove temporary files from a folder.

    #!/bin/bash
    rm `find $1 | grep "~$"`

I called the above file **rmm** and I put it in /usr/bin/ folder.
To use it, just place in the folder you have files with trailing slashes and execute it:  

    $ rmm .

Or directly passing the folder as the first argument:

    $ rmm /home/matteo/src

This script is trivial and can be obviously improved. If you want to contribute I will be happy to add your improvements.
