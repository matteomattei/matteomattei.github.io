---
title: jPolygon 
author: Matteo Mattei
layout: project
image_url: 
album: 
sitemap:
  lastmod: 2015-09-11
  priority: 0.7
  changefreq: monthly
categories:
  - javascript 
  - html5
  - canvas
---

jPolygon is a javascript library that allows drawing a polygon in a HTML5 canvas over an image.
It supports undo and clear funcions. To finalize the polygon press **CTRL + mouse Click**.

Technologies used:
------------------

 - pure javascript (no jQuery, etc...)
 - HTML5 canvas

Requirements:
-------------

 - Any browser that supports HTML5 canvas

Main Features:
--------------

 - Mark points with a square.
 - Undo function implementation.
 - Clear function implementation.
 - When a polygon is created, fill the content with a transparent color.

License:
--------

 - MIT license

URL:
----

 - Project sources are hosted on [Github](https://github.com/matteomattei/jPolygon)
 - A live demo is available [here](example.html)

USAGE:
------

Include the jPolygon.js script just before the ```</body>```:

```
        <script type="text/javascript" src="jPolygon.js"></script>
    </body>
```

Then in your body put at least the following elements:

 - a canvas tag with the following attributes:
   - *id="jPolygon"*.
   - specify width and height.
   - add *data-imgsrc="image.jpg"*. The image can also be a remote or local URL.
   - onclick callback: *onclick="point_it(event)"*.
 - a textarea with *id="coordinates"*.
 - a button for undo with *undo()* callback.
 - a button for clear with *clear_canvas()* callback.

```
<canvas id="jPolygon" width="640" height="480" data-imgsrc="image.jpg" onclick="point_it(event)">
    Your browser does not support the HTML5 canvas tag.
</canvas>
<button onclick="undo()">Undo</button>
<button onclick="clear_canvas()">Clear</button>
<textarea id="coordinates" disabled="disabled" style="width:300px; height:200px;"></textarea>
```

Then load the image over the canvas using the onload callback in the open body tag:

```
<body onload="clear_canvas()">
```

