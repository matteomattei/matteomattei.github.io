---
title: Very simple graphical messagebox in Python useful for console applications with py2exe
description: If you have to develop text-only python script and bundle them in self-contained executables, it is often useful to have the support for simple graphical message box. This guide shows how to do it with the built-in Tk library.
author: Matteo Mattei
layout: post
permalink: /very-simple-graphical-messagebox-in-python-useful-for-console-applications-with-py2exe/
categories:
  - Python
  - py2exe
  - Tk
---
When I have to develop background console applications in Python that have to be executed in Windows, I usually use py2exe and Inno Setup for creating installer. However the big issue is always how to report and show errors to the users. My preferred solution is to keep the application as a pure console application (no graphical), set the py2exe application as a window application and handle the errors with graphical messagebox.

And since the Tk library is included in the Python standard library, it is worth using it.

{% gist matteomattei/b2205a6b480b5a9faa8e %}

Lines 10 and 11 are needed to don't show the main Tk window in background.  
Updated with support for both python 2.7 and python 3.x
