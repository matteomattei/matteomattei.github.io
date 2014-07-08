---
title: PySide Signals and Slots with QThread example
description: This is an example of threading using QThread and signal/slots of Qt libraries in Python using PySide. The same concepts should also be valid for PyQt bindings.
author: Matteo Mattei
layout: post
permalink: /pyside-signals-and-slots-with-qthread-example/
categories:
  - Python
  - PySide
  - Qt
  - Thread
---
In these days I started studying PySide. After some days spent in reading lot of stuff, I thought that a real example could be useful for who intends to start learning PySide as well. In this example I can show you how you can implement a custom signal (MySignal) together with the usage of threads with QThread.

The following code creates a window with two buttons: the first starts and stop a thread (MyThread) that runs a batch that prints a point in the stdout every seconds continuously. The second button lets you only start another thread (MyLongThread) that prints an asterisk in the stdout every second for 10 seconds.

This example uses the api version 2 (introduced with PyQt 4.5) to connect signals to slots.

{% gist matteomattei/a62338bac981c34f301f %}

For more information you can look at:  
QThread documentation: http://doc.qt.nokia.com/latest/qthread.html
PySide signals and slots: http://developer.qt.nokia.com/wiki/Signals_and_Slots_in_PySide  
PyQt api 2 on PySide: <http://www.pyside.org/docs/pseps/psep-0101.html>
