#/bin/bash
#
# This script will run grunt and jekyll serve simultaneously

usage () {
  echo -e "$0 starts grunt and the jekyll server with watch"
  echo -e "Usage: $0 [-b <string:baseurl>]"
  echo -e "\t-b: baseurl for jekyll config"
}

b=""

while getopts "b:" o; do
  case "${o}" in
    b)
      b=${OPTARG}
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))


grunt & jekyll serve -w --baseurl $b && fg
