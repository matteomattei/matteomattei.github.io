---
title: How to calculate the number of inserted, deleted and modified lines in Subversion
author: Matteo Mattei
layout: post
permalink: /how-to-calculate-the-number-of-inserted-deleted-and-modified-lines-in-subversion/
categories:
  - Bash
  - Linux
  - SVN
---
If you need to calculate the number of inserted, deleted or modified lines in Subversion between two separate commits, you can use a simple script like this:

```
#!/bin/bash

FIRST_REV=${1}
LAST_REV=${2}
REPO_ROOT=${3}

if [ -z "${FIRST_REV}" ] || [ -z "${LAST_REV}" ] || [ -z "${REPO_ROOT}" ]
then
    echo "usage: ${0} first_revision last_revision repository_root"
    exit 1
fi

STAT=$(svn diff -r${FIRST_REV}:${LAST_REV} ${REPO_ROOT} 2> /dev/null | diffstat -m -t)

INS=0
DEL=0
MOD=0

for f in ${STAT}
do
    ins=$(echo ${f} | awk -F',' '{print $1}')
    del=$(echo ${f} | awk -F',' '{print $2}')
    mod=$(echo ${f} | awk -F',' '{print $3}')

    INS=$((${INS}+${ins}))
    DEL=$((${DEL}+${del}))
    MOD=$((${MOD}+${mod}))
done

echo "INSERTED=${INS}"
echo "DELETE=${DEL}"
echo "MODIFIED=${MOD}"
```
