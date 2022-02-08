#!/bin/sh

# Replace configration file 
echo "Template"
cat < ./config-template.yaml
envsubst < ./config-template.yaml > ./config.yml
echo "Generated config"
cat < ./config.yml

# Run the light-client
./avail-light
