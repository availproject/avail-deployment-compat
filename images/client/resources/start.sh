#!/bin/sh

# Replace configration file 
echo "## File config-template.yaml "
echo "##############################"
cat < ./config-template.yaml
envsubst < ./config-template.yaml > ./config.yaml
echo ""

echo "## Generated config.yaml"
echo "##############################"
cat < ./config.yaml
echo ""

echo "Avail-light version: $(./avail-light --version)"

# Run the light-client
echo "## Run light-client"
sleep 60
./avail-light
