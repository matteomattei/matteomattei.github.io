---
title: Use Python to print labels with Dymo LabelWriter 450 Turbo 
description: Dymo is a leading company for label printing. I show you how to use Python to print labels created with Dymo software on Windows.
author: Matteo Mattei
layout: post
permalink: /use-python-to-print-labels-with-dymo-labelwriter-450/
img_url:
categories:
  - python
  - dymo
  - labels
---
[**Dymo**](http://www.dymo.com) is a leading company for label printing. Altought several things can be done using their **DYMO Label v.8 Software**, I found that there was no way to set a specific date in a label layout so that every time I need to print a label I have the current date plus 30 days. I read the manual and I found that to do it we have to use a *variable field* but this is something that has to be handled using an external program.

So I wrote a little python tool that runs on Windows 7 and that does exactly what I need.
Make sure to install **pywin32** since we are going to use COM apis.

This is my example label (*my.label*) and the related Python code:

{% gist matteomattei/4a80294307e5d8075891 %}

As you can see I have two fields in the XML with **IsVariable** set to **True** and I have assigned to them the name **TEXT1** and **TEXT2**.
Now, all the logic happens between line 30 and line 41 of the Python script.

 * I initialize the Dispatch for the printer, configure the label I want to use (*mylabel*) and then I select the printer [lines 30-34].
 * Then I apply my rules to the variables **TEXT1** and **TEXT2** [lines 36-37].
 * And finally I launch the print job [lines 39-41].

That's all! With only few lines of Python code we are able to print a label using our Dymo LabelWriter 450 Turbo printer.

Note: the full code is available on [GitHub](https://github.com/matteomattei/PyDymoLabel) including the scripts to build a self-contained executable.
