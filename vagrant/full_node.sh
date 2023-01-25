#! /bin/bash

# sudo apt-get update
# sudo apt-get -y upgrade

echo "Killing Avail process"
sudo killall data-avail

mkdir -p /home/vagrant/avail
cp /home/vagrant/sync_folder/full-node/data-avail /home/vagrant/avail/data-avail

cd /home/vagrant/avail || exit
echo "Starting up Avail full node..."
nohup ./data-avail --dev --tmp --unsafe-rpc-external --unsafe-ws-external &> full_node_logs.txt &