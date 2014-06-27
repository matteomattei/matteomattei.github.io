---
title: How to record video streaming
author: Matteo Mattei
layout: post
permalink: /how-to-record-video-streaming/
categories:
  - Linux
  - Multimedia
tags:
  - mplayer
  - streaming
---
I often see beautiful streaming videos in a variety kind of formats and some people that are trying to grab those videos without any concrete result. I want to share with you how to capture those streams and convert them in a more **usable** AVI format.

Well... the only thing to do is open a shell on Linux and check if you have installed mplayer, then run this simple command

    $ mplayer "mms://url" -dumpstream -dumpfile video_out.avi

Where:

 - **mms://url** is the URL of the video stream.
 - **video_out.avi** is the output of the recorded video.

That's all.

**Note:**  
This trick is only available for streams play-ables with mplayer. For sites like Youtube or similar that encode video in flash format, you can't do it.

**Disclaimer:**
*Some sites licenses cannot allow to grab any video. So, please read carefully sites licenses before record any streams.*
