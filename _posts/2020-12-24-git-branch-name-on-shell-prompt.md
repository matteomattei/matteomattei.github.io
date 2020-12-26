---
title: Show Git branch name on shell prompt
description: A simple guide on how to show git branch name in shell prompt
author: Matteo Mattei
layout: post
permalink: /show-git-branch-name-on-shell-prompt/
img_url:
categories:
  - git
  - bash
  - shell
  - linux
---

Maintaining multiple git repositories might became a mess specially if you often switch from one folder to another and if you are used to work on different branches. Basically you have to type every time `git branch` on the terminal to make sure to work on the correct working copy.

If your OS is Linux (or MacOSx) and you have Bash installed, you can customize the Bash prompt to always show the current branch name in your working directory.

First of all type ensure your default shell is **/bin/bash**

```
matteo@barracuda ~ $ echo $SHELL
/bin/bash
```

Then edit _~/.bashrc_ file and add the following lines at the bottom:

```
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

PS1="\u@\h \[\e[32m\]\w \[\e[91m\]\$(parse_git_branch)\[\e[00m\]$ "
```

Basically we added the **parse_git_branch()** function which prints out the current git branch (if you are in a git project) and then reset the PS1 variable (the Bash prompt) calling the previously function.

Now you have to enable the new configuration just typing the following or doing a new login:

```
matteo@barracuda ~ $ . ~/.bashrc
```

Let's try and see how it looks like:

```
matteo@barracuda ~ $ cd src/myproject
matteo@barracuda ~/src/myproject (master)$
```

That's all! If you like to change colors or other PS1 parameters you can refer to the following resources:

- [Bash colors and formatting](https://misc.flogisoft.com/bash/tip_colors_and_formatting)
- [PS1 syntax variables](https://ss64.com/bash/syntax-prompt.html)
