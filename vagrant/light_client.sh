#! /bin/bash

echo "FULL_NODE_PUBLIC_IP: ""$1"
echo "BOOTSTRAP_LC_PUBLIC_IP: ""$2"
echo "LIGHT_CLIENT_NUMBER_PER_VM: ""$3"

# sudo apt-get update
# sudo apt-get -y upgrade

echo "Killing avail-light processes"
sudo killall avail-light

echo "Removing previous light client states"
sudo rm -rf avail-light-client

mkdir -p /home/vagrant/avail-light-client
cd /home/vagrant/avail-light-client || exit

echo "Initializing and starting up Avail light clients..."

for ((i=1; i <= $3; i++))
do
    echo "Starting client number $i"
    mkdir -p /home/vagrant/avail-light-client/lc$i
    cp /home/vagrant/sync_folder/light-client/avail-light /home/vagrant/avail-light-client/lc$i/avail-light
    cp /home/vagrant/sync_folder/light-client/config_light_client.yaml /home/vagrant/avail-light-client/lc$i/config.yaml
    cd lc$i || exit 
    {
        echo "bootstraps = [[\"12D3KooWStAKPADXqJ7cngPYXd2mSANpdgh1xQ34aouufHA2xShz\",\"/ip4/$2/tcp/39000\"]]"
        echo "full_node_rpc = [\"http://$1:9933\"]"
        echo "full_node_ws = [\"ws://$1:9944\"]"
        echo "libp2p_port = \"3700$i\""
        echo "http_server_port = \"700$i\""
        echo "prometheus_port = 952$i"
    } >> config.yaml
    
    nohup ./lc$i/avail-light &> avail-light-client.txt &
    cd ..
done



