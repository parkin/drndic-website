#!/bin/bash

grunt build
jekyll build

./deploy-help.sh 'publish'
