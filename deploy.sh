#!/bin/bash

# This is a script to build and deploy the site to the publish branch

grunt build
jekyll build

./deploy-help.sh 'publish'
