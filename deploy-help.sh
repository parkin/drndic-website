#!/bin/bash

set -ex

REPO="root@drndiclab-bkup.physics.upenn.edu:/c/shared/Website/drndicgroup.git"

PUBLISH_BRANCH=$1
DIR=temp-publish-clone
WEBSITE_DIR=_site

# Delete any existing temporary website clone
rm -rf $DIR

# Clone the current repo into temp folder
# done this way so we only check out the publish branch
mkdir $DIR
cd $DIR
git init
git remote add -t $PUBLISH_BRANCH -f origin $REPO
git checkout $PUBLISH_BRANCH

# Delete everything
rm -rf *

# Copy website files from real repo
# Use rsync so we can ignore hidden files
rsync -av --exclude=".*" ../$WEBSITE_DIR/* .

# Stage all files in git and create a commit
git add .
git add -u
git commit -m "Website at $(date)"

# Push the new files up to GitHub
git push origin $PUBLISH_BRANCH

# Delete our temp folder
cd ..
rm -rf $DIR
