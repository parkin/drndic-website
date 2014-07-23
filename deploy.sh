#!/bin/bash

grunt
jekyll build

./deploy-help.sh 'publish'
