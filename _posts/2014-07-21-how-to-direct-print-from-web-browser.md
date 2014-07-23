---
title: How to direct print from web browser 
description: This article explains the various ways to achive the objective to print directly from a web browser.
author: Matteo Mattei
layout: post
permalink: /how-to-direct-print-from-web-browser/
categories:
  - print
  - web
  - browser
---

Fortunately the web browsers have been created to protect the client environment from executing client processes and accessing client resources. However sometimes this limitation is too strong and does not let us to do some simple things like direct print a document without opening an intermediate print pop-up.

I searched in Google for a long time and experimented several tests before summarizing all possibilities I found. There is no a single way to achieve it and every option has some pros and cons depending on the environment and conditions you have.

Direct printing using a system call
-----------------------------------

**Requirements:**

 - A web server installed (I only consider a Linux server).
 - A printer directly connected to the web server.

**Pros:**

 - You have the full control of the printer parameters.
 - This option allow you to use every browser.
 - You can print a file or a document without creating a web layout for it.
 
**Cons:**

 - You can use the application only on the same PC that holds the web server (and the printer).
 - At least you can install the web application in the company server with a Network printer.
 
**Details:**
The idea here is to have a web server running for example Apache and PHP (but every other server-side language would be OK). On the same PC a printer is connected and configured using CUPS (on Linux). When a user clicks a button or a link in the web page, a PHP script executes a system() call to **lpr** that creates one ore more printer jobs depending on the number of documents passed.

{% gist matteomattei/cf4c0b2136f523160efa %}

The function above accepts a string of documents (space separated), sends a printer command and then polls the printer queue (the spooler) using **lpd** command and wait for the printer to return *ready*. Just for reference, the above function is a snippet of code I used to print barcodes with a Dymo LabelWrite 450 Turbo and 99012 paper labels.

<div class="video-container">
<iframe width="1280" height="720" src="//www.youtube.com/embed/eFkj4FVTaow?rel=0" frameborder="0" allowfullscreen></iframe>
</div>


Direct printing using browser options
-------------------------------------

**Requirements:**

 - A compatible web browser (Firefox or Chrome).
 - Direct access to the user browser.

**Pros:**

 - You don't need to have a web server running on the same machine.
 - The web application can be remote.
 - You can print what you see in the browser using just HTML and CSS.

**Cons:**

 - You need to create a web layout for a document with HTML and CSS.
 - You don't have access to all printer options.
 - Limited number of supported browsers.
 - You must have access to the web browser to change configuration.
  
**Details:**
In this case we have to modify the preferences of the web browser and/or execute it in a particular mode (like kiosk mode for example). As you know, every browser has a different configuration... From the web side we can use the Javascript ```window.print()``` function. Use the following instructions based on the web browser you are using:

 1. **Chrome**
 You need to have Chrome version 18.0.1 or higher. From Chrome, open a new tab and type ```info:config``` then make sure the *Disable Print Preview* flag is NOT enabled (Print preview must be enabled for Kiosk Printing to work). Now set your application the default page to open when Chrome launches and then close the browser. Now you have to execute Chrome in kiosk mode. To do it just append ```--kiosk --kiosk-printing``` to the chrome executable. Chrome should now start in kiosk mode (full-screen) and from here you should be able to print directly from the browser.
 
 2. **Firefox**
 In Firefox open a new tab and type ```about:config``` in the address bar. Then right click on the white space and select *NEW* > *BOOLEAN* and in the text edit that appears type ```print.always_print_silent```, hit OK and then select ```true```. This procedure writes a line to *prefs.js* file (on Windows) or *user.js* file on Linux and the next time you start the browser, any Javascript print(); function will print directly to the printer using the currently configured print settings.

You can use the following test page to test the direct printing using browser options:

{% gist matteomattei/cffe4d60eae42315d00a %}

