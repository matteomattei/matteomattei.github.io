---
title: Create a self-contained installer in Bash
description: In this article I show you how to create a simple self-contained installer in Bash that will extract an archive and perform some actions.
author: Matteo Mattei
layout: post
permalink: /create-self-contained-installer-in-bash-that-extracts-archives-and-perform-actitions/
img_url:
categories:
  - linux
  - bash
  - installer
---
In this post I will show you how to develop a self contained Linux command line installer in Bash that will decompress an archive and perform some tasks.

Installer content
--------------------
Our installer that is basically a self-extracting archive with some logic around, consists in three parts: 

 - A bash script that performs the extraction of the archive and applies some logic.
 - A marker to separate the bash script and the archive.
 - An archive containing the actual data to install.

Start now!
------------

Create a new bash script called ```installer.sh``` with the following content:

```
#!/bin/bash

echo ""
echo "My Command Line Installer"
echo ""

# Create destination folder
DESTINATION="/opt/my_application"
mkdir -p ${DESTINATION}

# Find __ARCHIVE__ maker, read archive content and decompress it
ARCHIVE=$(awk '/^__ARCHIVE__/ {print NR + 1; exit 0; }' "${0}")
tail -n+${ARCHIVE} "${0}" | tar xpJv -C ${DESTINATION}

# Put your logic here (if you need)

echo ""
echo "Installation complete."
echo ""

# Exit from the script with success (0)
exit 0

__ARCHIVE__
```

This script is self-explain but I will try to describe the steps:

 1. Create a destination folder **${DESTINATION}**.
 2. Find **__ARCHIVE__** marker and put the tarball content into **${ARCHIVE}** variable.
 3. Decompress the tarball into the destination folder.
 4. Eventually apply your installation logic (copy some files, change some others, etc...).
 5. Exit from the script (this step is mandatory otherwise bash will try to interpret the tarball and will exit with error).
 6. Add **__ARCHIVE__** marker at the bottom of the script. This marker will be used to separate the actual bash script with the tarball content.

Now generate a compressed tarball of your application (I used **.tar.xz** in the above example):

```
tar cJf myarchive.tar.xz /folder/to/archive
```

OK, now append it to the installer bash script and make it executable:

```
cat myarchive.tar.xz >> installer.sh
chmod +x installer.sh
```

That's all! You can now distribute your installer.

Execute your installer
--------------------------

The users will execute your installer simply running:

```
./installer.sh
```
