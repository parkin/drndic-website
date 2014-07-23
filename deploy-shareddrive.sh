#/bin/bash

# This is a script to build and deploy the site to the publish-shareddrive branch,
# which requires a different baseurl that is found in _config_shareddrive.yml

grunt build
jekyll build --config _config.yml,_config_shareddrive.yml

./deploy-help.sh 'publish-shareddrive'
