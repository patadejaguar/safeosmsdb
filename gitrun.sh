#!/bin/bash

git init
git add *
git commit -m "$1"
git remote add origin https://github.com/patadejaguar/safeosmsdb.git
git fetch -u origin master
git push -u origin master

exit 0;
