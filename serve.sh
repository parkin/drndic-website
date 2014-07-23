#/bin/bash
#
# This script will run grunt and jekyll serve simultaneously

grunt & jekyll serve -w --baseurl "" && fg
