#!/bin/sh

# Replace configration file 
echo "## File config-template.yaml "
echo "##############################"
cat < ./config-template.yaml
envsubst < ./config-template.yaml > ./config.yml
echo ""

echo "## Generated config.yaml"
echo "##############################"
cat < ./config.yml
echo ""

# Run the light-client
echo "## Run light-client"
./avail-light
