#!/bin/bash

# This script checks out the branch supplied 

if [ -z "$1" ]
  then
    echo -e "deploy-help checks out a branch and copys the _site folder to the branch's root. Usage:\n\t $ ./deploy-help.sh [branch]\t (default: publish-shareddrive)"
    $1='publish-shareddrive'
fi

set -ex

PUBLISH_BRANCH=$1
WEBSITE_DIR=_site

# get the current branch name
branch_name="$(git symbolic-ref HEAD 2>/dev/null)" ||
branch_name="(unnamed branch)"     # detached HEAD

branch_name=${branch_name##refs/heads/}

# Move to the publish branch

git checkout $PUBLISH_BRANCH
git pull

# Copy website files from real repo
# Use rsync so we can ignore hidden files
rsync -av --exclude=".*" $WEBSITE_DIR/* .

# Stage all files in git and create a commit
git add .
git add -u
git commit -m "Website at $(date)"

# Push the new files up to GitHub
git push origin $PUBLISH_BRANCH

# move back to the old branch
git checkout $branch_name
