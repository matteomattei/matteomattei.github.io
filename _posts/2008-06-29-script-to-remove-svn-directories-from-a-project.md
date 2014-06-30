---
title: Script to remove .svn directories from a project
author: Matteo Mattei
layout: post
permalink: /script-to-remove-svn-directories-from-a-project/
categories:
  - bash
  - linux
  - svn
  - tricks
---
When you want to distribute your own sources without any .svn directories is sufficient to create an export of the project with this command:  

```
svn export svn://path_to_repository projectname
```

But often I have not access to the repository, so I remove any **.svn** directory by hand.

For a couple of directories is not a problem but today I have a big project with hundreds of directories, so I created a little script to help me:

```
find . -type d -name .svn -exec rm -r '{}' \;
```

Replace "." with your root folder.
