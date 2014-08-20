#!/bin/bash

# This script checks out the branch supplied 

function usage() { 
  echo -e "$0 builds the website and commits it to a publish branch."
  echo -e "Usage: $0 [OPTIONS] ... [-u <shareddrive username>]"
  echo -e "\tChoose what you want to do:"
  echo -e "\t\t-b: Build the site with grunt and jekyll. (DEFAULT)"
  echo -e "\t\t-c: Commit and push to appropriate git publish branch. (DEFAULT)"
  echo -e "\t\t-r: Release to publish servers (currently only shared drive) (DEFAULT)"
  echo -e "\t\t\t-u: Shared drive username (Optional)"
  echo -e "\t\t\t-n: facstaff username (Optional)"
  echo -e "\tChoose the branch(es):"
  echo -e "\t\t-s: Build website for the shared drive, branch: public. (DEFAULT)"
  echo -e "\t\t-f: Build website for publish on the facstaff server, branch: public-shareddrive."
  echo -e "\t-h: Help"
  echo -e "\nExamples:"
  echo -e "\t./deploy.sh -b  (only build and only the shared drive version)"
  echo -e "\t./deploy.sh -bcrsf  (do everything)"
  echo -e "\t./deploy.sh -rs -u username  (release to the shared drive with username)"

  exit 1;
}

# what to do
b=false
c=false
r=false
u=""
# which branch to publish to
s=false
s_branch="publish-shareddrive"
s_config="_config_shareddrive.yml"
s_dir="_site_shareddrive"
s_url="drndiclab-bkup.physics.upenn.edu"
s_server_repo_loc="/c/shared/Website/drndicgroup"
f=false
f_branch="publish"
f_config="_config_facstaff.yml"
f_dir="_site_facstaff"
f_url="web-facstaff.sas.upenn.edu"
f_server_repo_loc="/www-physics/data/drndicgroup"

while getopts "bpcfsru:n:h" o; do
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
    r)
      r=true
      ;;
    u)
      u=${OPTARG}
      ;;
    n)
      n=${OPTARG}
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

if ! ( ${b} || ${c} || $r); then
  b=true
  c=true
  r=true
fi
if ! ( ${f} || ${s}); then
  s=true
fi

# get the current git branch name
branch_name="$(git symbolic-ref HEAD 2>/dev/null)" ||
branch_name="(unnamed branch)"     # detached HEAD
branch_name=${branch_name##refs/heads/}

# check to make sure we aren't running grunt or jekyll serve already
check_serve () {
  # check processes for 'jekyll' or 'grunt', but ignore the 'grep' commands
  local check=$(ps aux | grep 'jekyll\|grunt' | grep -v grep)
  # if it's not an empty string, we have running processes
  if ! [ -z "${check}" ] ; then
    echo -e "Error. Watch processes running that will affect the build. Please stop the processes before continuing:\n${check}" 1>&2
    exit 1
  fi
}

# Builds the website
# $1 - the publish branch config file
build_site () {
  check_serve

  grunt build
  jekyll build --config _config.yml,$1
}

# Checks
#
# $1 - git publish branch
# $2 - _site dir
push_git () {
  check_serve

  typeset publish_branch=$1
  typeset site_dir=$2

  # Move to the publish branch

  git checkout $publish_branch
  git pull

  # Copy website files from real repo
  # Use rsync so we can ignore hidden files
  echo "Copying files from ${site_dir}"
  rsync -a --exclude=".*" ${site_dir}/* .

  # Stage all files in git and create a commit
  git add .
  git add -u
  git commit -m "Website at $(date)"

  echo "Pushing ${1}"
  # Push the new files up to GitHub
  git push origin ${publish_branch}

  echo "Switching back to ${branch_name}"
  # move back to the old branch
  git checkout ${branch_name}
}

# $1 - server url
# $2 - server username (can be empty, will prompt if empty)
# $3 - git repo location
# $4 - git branch
release_to_wild() {
  echo "Releasing ${4} to the wild at ${2}@${1}:${3}"

  ssh ${2}@${1} "cd ${3} && git checkout ${4} && git pull"

}

# $1 - config file
# $2 - branch
# $3 - _site dir
do_deploy () {
  if ${b}; then
    build_site $1
  fi
  if ${c}; then
    push_git $2 $3
  fi
}

# $1 - drive name
# $2 - variable to result in
# $3 - current value
get_username () {
  local _result=$2
  local username=$3
  # If user didn't input username, prompt here.
  if [ -z "${username}" ]; then
    while true; do
      read -p "Username for $1: " username
      if [ -z "${username}" ]; then
        echo -e "\nPlease enter a username!"
      else
        break 2
      fi
    done
  fi

  if [[ "$_result" ]]; then
    eval $_result="'$username'"
  else
    echo "$username"
  fi
}

# If we want to execute for the shared drive, try the following.
if ${s}; then
  do_deploy ${s_config} ${s_branch} ${s_dir}
  if ${r}; then
    get_username ${s_url} u $u
    release_to_wild ${s_url} ${u} ${s_server_repo_loc} ${s_branch}
  fi
fi

# If we want to execute for the facstaff servers, try the following.
if ${f}; then
  do_deploy ${f_config} ${f_branch} ${f_dir}
  if ${r}; then
    get_username ${s_url} u $u
    release_to_wild ${f_url} ${u} ${f_server_repo_loc} ${f_branch}
  fi
fi

