#!/bin/bash
#
# Logs in to the shared drive, cd's into the website repo, and pulls

set -e

usage() { echo "Usage: $0 [-u <string:username>]" 1>&2; exit 1; }

while getopts "u:" o; do
  case "${o}" in
    u)
      u=${OPTARG}
      ;;
  esac
done
shift $((OPTIND-1))

# If user didn't input username, prompt here.
if [ -z "${u}" ]; then
  while true; do
    read -p "shared drive username:" u
    if [ -z "${u}" ]; then
      echo -e "\nPlease enter a username!"
    else
      break 2
    fi
  done
fi

SH_DRIVE="drndiclab-bkup.physics.upenn.edu"

ssh ${u}@${SH_DRIVE} "cd /c/shared/Website/drndicgroup && git pull"

