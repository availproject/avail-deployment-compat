# Vagrant for local deployment

Local deployment is based on VMware virtual machines with shell scripts used as simple providers.

## Setup

1. Install [Vagrant](https://developer.hashicorp.com/vagrant/docs/installation)
2. Install VMware [provider](https://developer.hashicorp.com/vagrant/docs/providers/vmware/installation) and Vagrant VMware [Utility](https://developer.hashicorp.com/vagrant/docs/providers/vmware/vagrant-vmware-utility)
3. Copy `data-avail` full node binary to `sync_folder/full-node`
4. Copy `avail-light` light client binary to `sync_folder/light-client`
5. Execute `vagrant up` in vagrant directory containing Vagrantfile

## Use

- use `vagrant ssh vm_name` to access individual VMs
- use `vagrant destroy -f` to destroy entire network (stop and delete all files)
- use `vagrant provision vm_name` to re-execute provision script for that VM

## Notes

- Vagrant [documentation](https://developer.hashicorp.com/vagrant/docs)
- Only one full node is being deployed, for now
- Fat clients deployment has to be done with regards to partitioning
- Ports and partition parts of light client configs have to be dynamically generated
- Logs are being saved in local txt files (not in JSON format, that can be changed through config file)
- Full node is deployed with `--dev --tmp --unsafe-rpc-external --unsafe-ws-external` flags in order for other clients to be able to connect to it
- IP allocation has been done manually without using DHCP because of subnet configuration issues with VMware
