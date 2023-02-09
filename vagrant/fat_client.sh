#! /bin/bash

# sudo apt-get update
# sudo apt-get -y upgrade

echo "FULL_NODE_PUBLIC_IP: ""$1"
echo "BOOTSTRAP_LC_PUBLIC_IP: ""$2"
echo "FAT_CLIENT_NUMBER_PER_VM: ""$3"

echo "Killing avail-light processes"
sudo killall avail-light

echo "Removing previous fat client states"
sudo rm -rf avail-fat-client

mkdir -p /home/vagrant/avail-fat-client
cd /home/vagrant/avail-fat-client || exit

echo "Initializing and starting up Avail light clients..."

for ((i=1; i <= $3; i++))
do
    # Fat client ordering has to be sequential because of the partitioning logic
    client_number=$((($4-1)*$3+i))
    echo "Starting client number $client_number"
    mkdir -p /home/vagrant/avail-fat-client/fc"$client_number"
    cp /home/vagrant/sync_folder/light-client/avail-light /home/vagrant/avail-fat-client/fc"$client_number"/avail-light
    cp /home/vagrant/sync_folder/light-client/config_fat_client.yaml /home/vagrant/avail-fat-client/fc"$client_number"/config.yaml
    cd fc"$client_number" || exit 
    {
        echo "bootstraps = [[\"12D3KooWStAKPADXqJ7cngPYXd2mSANpdgh1xQ34aouufHA2xShz\",\"/ip4/$2/tcp/39000\"]]"
        echo "full_node_rpc = [\"http://$1:9933\"]"
        echo "full_node_ws = [\"ws://$1:9944\"]"
        echo "libp2p_port = \"370$(printf "%02d" $i)\""
        echo "http_server_port = \"70$(printf "%02d" $i)\""
        echo "prometheus_port = 95$(printf "%02d" $i)"
        echo "block_matrix_partition = \"$client_number/$5\""
    } >> config.yaml
    
    nohup ./avail-light &> avail-fat-client.txt &
    cd ..
done