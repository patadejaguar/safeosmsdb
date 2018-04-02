#!/bin/bash

REPO="pt"

git init
git add *
git commit -m "$1"
git remote add origin https://github.com/patadejaguar/safeosmsdb.git

#If exists the repo
git fetch -u origin $REPO

git push -u origin $REPO

exit 0;
