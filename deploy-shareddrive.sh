#/bin/bash

grunt build
jekyll build --config _config.yml,_config_shareddrive.yml

./deploy-help.sh 'publish-shareddrive'
