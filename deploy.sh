#!/bin/bash

# This script checks out the branch supplied 

set -e

function usage() { 
  echo -e "$0 builds the website and commits it to a publish branch."
  echo -e "Usage: $0 [OPTIONS] ... "
  echo -e "\tChoose what you want to do:"
  echo -e "\t\t-b: Build the site with grunt and jekyll. (DEFAULT)"
  echo -e "\t\t-c: Commit and push to appropriate git publish branch. (DEFAULT)"
  echo -e "\tChoose the branch(es):"
  echo -e "\t\t-s: Build website for the shared drive, branch: public. (DEFAULT)"
  echo -e "\t\t-f: Build website for publish on the facstaff server, branch: public-shareddrive."
  echo -e "\t-h: Help"
  echo -e "\nExamples:\t./deploy.sh -b  (only build and only the shared drive version)"

  exit 1;
}

# what to do
b=false
c=false
# which branch to publish to
s=false
s_branch="publish-shareddrive"
s_dir="_site_shareddrive.yml"
f=false
f_branch="publish"
f_dir="_site_facstaff.yml"

while getopts "bpfsh" o; do
  case "${o}" in
    b)
      b=true
      ;;
    c)
      c=true
      ;;
    f)
      f=true
      ;;
    s)
      s=true
      ;;
    h)
      usage
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

# If user didn't input username, prompt here.
#if [ -z "${u}" ]; then
#  usage
#fi

if ! ( ${b} || ${c}); then
  b=true
  c=true
fi
if ! ( ${f} || ${s}); then
  s=true
fi

# get the current git branch name
branch_name="$(git symbolic-ref HEAD 2>/dev/null)" ||
branch_name="(unnamed branch)"     # detached HEAD
branch_name=${branch_name##refs/heads/}


# Builds the website
# $1 - the publish branch config file
build_site () {
  grunt build
  jekyll build --config _config.yml,$1
}

# Checks
#
# $1 - git publish branch
# $2 - _site dir
push_git () {
  typeset publish_branch=$1
  typeset site_dir=$2

  # Move to the publish branch

  git checkout $publish_branch
  git pull

  # Copy website files from real repo
  # Use rsync so we can ignore hidden files
  rsync -av --exclude=".*" $site_dir/* .

  # Stage all files in git and create a commit
  git add .
  git add -u
  git commit -m "Website at $(date)"

  # Push the new files up to GitHub
  git push origin $publish_branch

  # move back to the old branch
  git checkout $branch_name
}

# If we want to execute for the facstaff servers, try the following.
if ${f}; then
  if ${b}; then
    build_site ${f_dir}
  fi
  if ${c}; then
    push_git ${f_branch} ${f_dir}
  fi
fi

# If we want to execute for the shared drive, try the following.
if ${s}; then
  if ${b}; then
    build_site ${s_dir}
  fi
  if ${c}; then
    push_git ${s_branch} ${s_dir}
  fi
fi
