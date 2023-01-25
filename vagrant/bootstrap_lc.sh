#! /bin/bash

# sudo apt-get update
# sudo apt-get -y upgrade

echo "FULL_NODE_PUBLIC_IP: ""$1"
echo "BOOTSTRAP_LC_PUBLIC_IP: ""$2"
echo "Killing avail-light processes"
sudo killall avail-light

mkdir -p /home/vagrant/avail-light/bootstrap
mkdir -p /home/vagrant/avail-light/lc1

cp /home/vagrant/sync_folder/light-client/avail-light /home/vagrant/avail-light/bootstrap/avail-light
cp /home/vagrant/sync_folder/light-client/config_bootstrap.yaml /home/vagrant/avail-light/bootstrap/config.yaml
cp /home/vagrant/sync_folder/light-client/avail-light /home/vagrant/avail-light/lc1/avail-light
cp /home/vagrant/sync_folder/light-client/config_light_client.yaml /home/vagrant/avail-light/lc1/config.yaml

cd /home/vagrant/avail-light/bootstrap || exit
{
    echo "full_node_rpc = [\"http://$1:9933\"]"
    echo "full_node_ws = [\"ws://$1:9944\"]"
} >> config.yaml
echo "Starting new avail-light bootstrap"
nohup ./avail-light &> bootstrap_lc_logs.txt &
cd ../lc1 || exit
{
    echo "bootstraps = [[\"12D3KooWStAKPADXqJ7cngPYXd2mSANpdgh1xQ34aouufHA2xShz\",\"/ip4/$2/tcp/39000\"]]"
    echo "full_node_rpc = [\"http://$1:9933\"]"
    echo "full_node_ws = [\"ws://$1:9944\"]"
} >> config.yaml
echo "Starting new avail-light client"
nohup ./avail-light &> lc_logs.txt &