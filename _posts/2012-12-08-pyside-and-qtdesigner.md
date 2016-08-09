---
title: PySide and Qt-designer
description: Simple snippet of Python code and instructions on how to join generated QtDesigner GUI and your PySide code.
author: Matteo Mattei
layout: post
permalink: /pyside-and-qtdesigner/
categories:
  - python
  - pyside
---
The tool to transform *myapplication.ui* generated with qt-designer in *myapplication_ui.py*, is called **pyside-uic** (if you use **PySide**, or **pyuic** if you use **PyQt**).
Its usage is straightforward:

Linux:
------

```
pyside-uic myapplication.ui > myapplication_ui.py
```

Windows:
--------

```
C:\python27\scripts\pyside-uic.exe myapplication.ui > myapplication_ui.py
```

But can happen the following error:

```
Traceback (most recent call last):
  File "C:\Python27\Scripts\pyside-uic-script.py", line 5, in <module>
    from pkg_resources import load_entry_point
ImportError: No module named pkg_resources
```

To fix the problem you need to intall **setuptools** from http://pypi.python.org/pypi/setuptools
Now to use the generated file you need to add the following code to your application:

{% gist matteomattei/e94d94098492e555db8a %}
