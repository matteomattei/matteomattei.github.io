---
title: HTML5 Ajax file upload
description: A simple and easy to use code that implements HTML5 ajax upload.
author: Matteo Mattei
layout: post
permalink: /html5-ajax-file-upload/
img_url:
categories:
  - html5
  - ajax
  - jquery
  - php
---
Very often I have to write HTML forms for uploading files and since I would like to have something responsive without a full page reload I decided to write a little script as example for the next time I will need something similar. The following example should be compatible with every browser but the actual *dynamic* part is only available on new browsers that support **FormData** object from *XMLHttpRequest2*. Old browsers should be able to upload the files using the old (standard) way with just few changes in the server side part.

The following example creates a form for uploading PDF files (checks at line 34) and show the list of uploaded files inside the *<div>* element with class *result*.

{% gist matteomattei/e275ff176673b2da2921 %}

The main components of the script are the following:

 - *FormData* object from XMLHttpRequest2.
 - *multiple* attribute of file input HTML field.
 - *FileReader* object from the new File API.

Remember to apply all needed checks in the PHP server side script.

Please note the ```TransferCompleteCallback()``` at line 10 that can be used to get the content of the files once they are transferred. This might be useful for example to directly render uploaded images to the screen without an additional request to the server to get them back.
