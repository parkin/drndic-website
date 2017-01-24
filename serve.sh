#/bin/bash
#
# This script will run grunt and jekyll serve simultaneously

# $1 - exit code
usage () {
  local exit_code=$1
  if ! [[ $exit_code =~ '^[0-9]+$' ]] ; then
    exit_code=1
  fi
  echo -e "$0 starts grunt and the jekyll server with watch"
  echo -e "Usage: $0"
  echo -e "\t-n: No drafts (drafts included by default)"
  echo -e "\t-e: External server. Serve on 0.0.0.0. (localhost is default)"
  echo -e "\t-h: for help"
  echo -e "\t-v: verbose output"

  exit $exit_code;
}

drafts="--drafts"
host="localhost"

while getopts "ehnv" o; do
  case "${o}" in
    e)
      host="0.0.0.0"
      ;;
    n)
      drafts=""
      ;;
    h)
      usage 0
      ;;
    v)
      set -x
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

# start both grunt and serve at the same time
# fg ensures that a ctrl-c kills both processes
grunt & jekyll serve -w ${drafts} --host ${host} && fg
