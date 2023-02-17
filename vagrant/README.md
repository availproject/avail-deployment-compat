# Vagrant for local deployment

Local deployment is based on VMware virtual machines with shell scripts used as simple providers.

## Setup

1. Install [Vagrant](https://developer.hashicorp.com/vagrant/docs/installation)
2. Install VMware [provider](https://developer.hashicorp.com/vagrant/docs/providers/vmware/installation) and Vagrant VMware [Utility](https://developer.hashicorp.com/vagrant/docs/providers/vmware/vagrant-vmware-utility)
3. Copy `data-avail` full node binary to `sync_folder/full-node`
4. Copy `avail-light` light client binary to `sync_folder/light-client`
5. Execute `vagrant up` in vagrant directory containing Vagrantfile to raise the entire network
6. Copy `target.json` file into Prometheus folder, if Prometheus frontend is used with [dynamic targets](https://prometheus.io/docs/guides/file-sd/#installing-configuring-and-running-prometheus)

## Nomad bridge setup

1. Copy _hardhat.config.js_ to `sync_folder/da-bridge/agents`, set mining to 5s
2. Copy monorepo to `sync_folder/da-bridge` and compile the source
3. Copy agents binary (updater, relayer, processor, watcher) to the `sync_folder/da-bridge/agents`

## Use

- use `vagrant ssh vm_name` to access individual VMs
- use `vagrant destroy -f` to destroy entire network (stop and delete all files)
- use `vagrant provision vm_name` to re-execute provision script for that VM
- use `vagrant provision /light_client/` to provision just the light client VMs (same goes for halt/destroy/up etc. commands)

## Notes

- Vagrant [documentation](https://developer.hashicorp.com/vagrant/docs)
- Only one full node is being deployed, for now
- Re-provisioning is needed on each restart
- Fat clients deployment has to be done with regards to partitioning
- Ports and partition parts of light client configs have to be dynamically generated
- Logs are being saved in local txt files (not in JSON format, that can be changed through config file)
- Full node is deployed with `--dev --tmp --unsafe-rpc-external --unsafe-ws-external` flags in order for other clients to be able to connect to it
- IP allocation has been done manually without using DHCP because of subnet configuration issues with VMware
- Load test tool is NOT included with this setup
