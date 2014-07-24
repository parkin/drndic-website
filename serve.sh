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
  echo -e "Usage: $0 [-b <string:baseurl>]"
  echo -e "\t-b: baseurl for jekyll config"

  exit $exit_code;
}

b=""

while getopts "b:h" o; do
  case "${o}" in
    b)
      b=${OPTARG}
      ;;
    h)
      usage 0
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))


grunt & jekyll serve -w --baseurl $b && fg
