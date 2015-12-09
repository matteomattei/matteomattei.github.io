---
title: How to create self contained executables in Python
description: A step by step guide on how to create self contained executables in Python using PyInstaller
author: Matteo Mattei
layout: post
permalink: /create-self-contained-executables-in-python/
img_url:
categories:
  - python 
---
This is a very quick guide on how to create self contained Python executables (for all platforms). First of all install [PyInstaller](http://www.pyinstaller.org) (I am using **pip3** because I work with Python 3.x):

```
sudo pip3 install pyinstaller
```

Now install **upx** for a better compression:

```
sudo apt-get install upx
```

Now you are ready to create your self-contained executable:

```
pyinstaller \
    --onefile \
    --noconfirm \
    --noconsole \
    --clean \
    --log-level=WARN \
    --key=MySuperSecretPassword \
    --strip \
    myscript.py
```

Resulting executable will be placed inside *dist* folder and it will be called *myscript*.
This is what each parameter does:

 - ``--onefile`` allows to create a single self contained binary.
 - ``--noconfirm`` replaces output directory without asking for confirmation.
 -  ``--noconsole`` should be used in GUI application with no console. ``--console`` should be used otherwise.
 - ``--clean`` cleans PyInstaller cache and remove temporary files.
 - ``--log-level=WARN`` shows only warnings and errors during build.
 - ``--key=yourkey`` uses the given key to encrypt the Python bytecode (yes it's secure!).
 - ``--strip`` removes debug information to executable and shared libraries.

For windows, if you want to add also the icon to the resulting exe file you can add this additional parameter:

```
--icon-file=myapplication.ico
```

The application have only to be recompiled on every platform you want to release your application for. I know, the resulting binary will be a little heavy (~24MB for a PySide GUI application on Linux) but we have to consider that it contains the interpreter itself and all the needed libraries!!!

