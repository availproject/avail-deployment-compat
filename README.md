# Data Availability Deployments
<a name="deployments"/>

#### Table of Contents
- [Data Availability Deployment](#deployments)
  - [Current Testnet Deployment](#deployments_testnet)
  - [TestNet Chain Specification](#deployments_chain_spec)
- [Run a Validator Node](#run_validator)
  - [Initial Set-up](#run_validator_init)
  - [Using Docker Image](#run_validator_docker)
  - [Bond AVL](#run_validator_bond)
  - [Set Session Keys](#run_validator_ssk)
  - [Validate](#run_validator_va)
- [How to Build Data Availability](#build)
  - [Build from source code](#build_src)
  - [Optional: How to Generate Deterministic WASM](#build_srtool)
- [Development Environment](#dev_env)
  -  [Build and Run Light Client and Data-Avail in Dev](#dev_env_build)


## Current Testnet Deployment
<a name="deployments_testnet"/>

| Bootnode   | Node IP  | P2P Discovery Address | 
| ---------- | -------- | ------------------------------------------------------------------------------------------------ |
| Bootnode 1 | `23.20.114.84` | `/ip4/23.20.114.84/tcp/30333/p2p/12D3KooWJfr2gxQ9pMfxDUm8wK3tVy4SwkbTGaP8t91882S95YZC`  |
| Bootnode 2 | `52.3.23.97`   | `/ip4/52.3.23.97/tcp/30333/p2p/12D3KooWCYeahoNTXSJzPGxwVzvLbYNQBjUhn8SFXrwi66o78ead` |
| Bootnode 3 | `44.205.165.4` | `/ip4/44.205.165.4/tcp/30333/p2p/12D3KooWAq5mHuHx8p6Lyi9eXTQcsUHWdKUAL2u3t8aJbsDBucVh`  |
| Full Node  | | [Explorer dApp](https://testnet.polygonavail.net/) | 

## TestNet Chain Specification 
<a name="deployments_chain_spec"/>

TestNet uses the following chain spec file: [testnet.chain.spec.raw.json](./ansible/templates/genesis/testnet-v2.chain.spec.raw.json)


# Run a Validator Node
<a name="run_validator"/>


## Initial Set-up
<a name="run_validator_init"/>

If you want to run a validator, you will need the following requirements:

a. A Standard Hareward, which is:
  - CPU - Intel(R) Core(TM) i7-7700K CPU @ 4.20GHz
  - Storage - A NVMe solid state drive. Should be reasonably sized to deal with blockchain growth. Starting around 80GB - 160GB will be okay for the first six months.
  - Memory - 64GB ECC

b. At least, **1000 AVL** to bound your validator.


## Using Docker Image
<a name="run_validator_docker"/>

This is the _easiest way_ to deploy your own validator on Data Availability. It only needs a couple
of steps:

### Run the latest version of the container

You can run using the default parameters, and exposing the P2P port using `-p 30333`.

	$> docker run -p 30333 --name my_val 0xpolygon/avail:latest 

Any extra parameter will be added to the `data-avail` binary as argument. If you want to use an
specific node key and limit the maximum number of incoming connections to `10`, you can use:

	$> docker run -p 30333 --name my_val 0xpolygon/avail:latest --in-peers=10 --node-key 80027666cebec66464611eb0d5c36416213d83a9c689006a80efcf479826de7d

This image uses 2 volumes:
  - `/da/state` to store the database of the chain, and
  - `/da/keystore` where the validator's private keys will be stored.

Most likelihood you want to bind these volumes to an specific points, like:

	$> docker run -p 30333 --name my_val -v /volumes/da/state:/da/state -v /volumes/da/keystore/:/da/keystore 0xpolygon/avail:latest

### Insert Validator's private keys

These private keys will be used by the validator to sign blocks and finalized chains when it acts as
active validator. They are stored into `/da/keystore` in plain text format, so you should take extra
care over that volume.

In order to insert these keys, we will open a shell inside the running container:

	$> docker exec -it my_val bash
	root@5f55e51e5a85:/da# /da/bin/data-avail key insert \
		--chain=/da/genesis/testnet.chain.spec.raw.json \
		--base-path=/da/state/ \
		--keystore-path=/da/keystore/ \
		--suri=0x7d98...cae6 \
		--key-type=babe \
		--scheme=Sr25519

The **--suri** parameter is the private key as secret seed (or secret phrase), and you can generate
one using the `subkey` tool from parity. This command should be **repeated for each pair of key type
and scheme** showed in the following table:

| Key Type | Scheme  |
| -------- | ------  |
| babe     | Sr25519 |
| gran     | *Ed25519* |
| imon     | Sr25519 |
| audi     | Sr25519 |


## Bond AVL
<a name="run_validator_bond"/>

It is highly recommended that you make your controller and stash accounts be two separate accounts. For this, you will create two accounts and make sure each of them have at least enough funds to pay the fees for making transactions. Keep most of your funds in the stash account since it is meant to be the custodian of your staking funds.

Make sure not to bond all your AVL balance since you will be unable to pay transaction fees from your bonded balance.

It is now time to set up our validator. We will do the following:

 - Bond the AVL of the Stash account. These AVL will be put at stake for the security of the network and can be slashed.
 - Select the Controller. This is the account that will decide when to start or stop validating.

First, go to the `Developer` top menu, and click on `Extrinsics`. Select the `staking` pallet, and 
the `bond` extrinsic. Create a transaction where your `stash` account bounds `1001 AVLs` at least to
your `controller` account, as you can see in the picture:

![Add Validator: Bound funds](.web_resources/add_validator_bound_step.png?raw=true "Bound funds")


- **Stash** account - Select your Stash account. In this example, we will bond 1001 `AVL`s, where the minimum bonding amount is 1000. Make sure that your Stash account contains at least this much. You can, of course, stake more than this.
- **Controller** account - Select the Controller account created earlier. This account will also need a _small amount of AVL_ in order to start and stop validating.
- **Value** bonded - How much `AVL` from the Stash account you want to bond/stake. Note that you do not need to bond all of the `AVL` in that account. Also note that you can always bond more `AVL` later. However, withdrawing any bonded amount requires the duration of the unbonding period.
- **Payment** destination - The account where the rewards from validating are sent. More info [here](https://wiki.polkadot.network/docs/learn-staking#reward-distribution).


## Set Session Keys
<a name="run_validator_ssk"/>

Once your node is **fully synced**, you need to rotate your session keys and submit them. 

### Rotate Your Session Keys

Run this command on the same machine (while the node is running with the default HTTP RPC port configured):

	$> docker exec -it my_val bash
	root@5f55e51e5a85:/da# curl \
		-H "Content-Type: application/json" \
		-d '{"id":1, "jsonrpc":"2.0", "method": "author_rotateKeys", "params":[]}' \
		http://localhost:9933

The output will have a hex-encoded "result" field. The result is the concatenation of the four public keys. Save this result for a later step.

You can restart your node at this point.

### Submitting the setKeys Transaction

You need to tell the chain your Session keys by signing and submitting an extrinsic. This is what associates your validator with your Controller account.

Go to `Staking` > `Account Actions`, and click "Set Session Key" on the bonding account you generated earlier. Enter the output `from author_rotateKeys` in the field and click "Set Session Key".


![Set Session Keys](.web_resources/add_validator_set_session_key.png?raw=true "Set session keys")


Submit this extrinsic, and you are now ready to start validating.


## Validate
<a name="run_validator_va"/>

To verify that your node is live and synchronized, head to `Network > Staking`, and section
`Waiting`. Your account should be shown there. A new validator set is selected every `Era`, based on
the staking amount.



# How to Build Data Availability
<a name="build"/>


## Build from source code
<a name="build_src"/>
1. Clone the repo and checkout the proper branch:

    $ git clone git@github.com:maticnetwork/avail.git

2. Build the _only_ the node binary 

    $ cargo build --release -p data-avail

## Optional: How to Generate Deterministic WASM
<a name="build_srtool"/>

**NOTE:** This step is **not required**, and it should be used only to verify that _WASM_ matches with
the source code.

The `srtool` allows building **WASM runtimes in a deterministic way**, allowing CIs and users, with 
various machines and OS, to produce a *strictly identical* WASM runtime.

1. Install [srtool-cli](https://github.com/chevdor/srtool-cli)

2. Move to your `substrate` root folder and build the WASM runtime:

    $ srtool build -r runtime/ --package da-runtime 

the output would be something like:

    Found 1.57.0, we will be using paritytech/srtool:1.57.0 for the build
    🧰 Substrate Runtime Toolbox - srtool v0.9.19 🧰
              - by Chevdor -
    info: using existing install for '1.57.0-x86_64-unknown-linux-gnu'
    info: override toolchain for '/build' set to '1.57.0-x86_64-unknown-linux-gnu'
    
    1.57.0-x86_64-unknown-linux-gnu unchanged - rustc 1.57.0 (f1edd0429 2021-11-29)
    
    🏗  Building node-template-runtime as release using rustc 1.57.0 (f1edd0429 2021-11-29)
    ⏳ That can take a little while, be patient... subsequent builds will be faster.
       Since you have to wait a little, you may want to learn more about Substrate runtimes:
       https://docs.substrate.io/v3/getting-started/architecture/
         Updating git repository `https://github.com/maticnetwork/plonk.git`
         Updating crates.io index
      Downloading crates ...
        Downloaded addr2line v0.17.0
        Downloaded void v1.0.2
        ...
        
        Compiling pallet-staking v3.0.0 (/build/frame/staking)
        Compiling pallet-babe v3.0.0 (/build/frame/babe)
          Finished release [optimized] target(s) in 5m 31s
     
    ✨ Your Substrate WASM Runtime is ready! ✨
    Summary generated with srtool v0.9.19 using the docker image paritytech/srtool:1.57.0:
     Package     : node-template-runtime v2.0.0
     GIT commit  : 0c920993026117aa83c905bfcbe881a71ae3e8a3
     GIT tag     : v3.0.0
     GIT branch  : da-poc-upgrade-3.0
     Rustc       : rustc 1.57.0 (f1edd0429 2021-11-29)
     Time        : 2022-01-18T15:55:30Z
     
    == Compact
     Version     : node-template-1 (node-template-1.tx1.au10)
     Metadata    : V12
     Size        : 1.75 MB (1832581 bytes)
     Proposal    : 0xb1b534eb700006140cc980c89c1f3a9ad7a5ababa3e2aa8b9a17c5ae71d9b61c
     IPFS        : QmanwTMjMhWL8uL974VzrA6XVUg17x7czYqEftop6dhkP2
     BLAKE2_256  : 0xa1f8434cba25d4bee440d61b9ce6eeaa0d948ff2173187d940e8c3d87086737c
     Wasm        : ./bin/node-template/runtime//target/srtool/release/wbuild/node-template-runtime/node_template_runtime.compact.wasm
     
    == Compressed
     No compressed runtime found

3. Now you only need to replace the WASM file in your `target/release` folder and rebuild the node
   binary. Another option is to replace the WASM code in `genesis > runtime > frameSystem > code` in
   your `chain.spec` file.


# Development Environment
<a name="dev_env"/>

## Build and Run Light Client and Data-Avail in Dev.
<a name="dev_env_build"/>

1. Build images, `client:asdr`(using branch `feature/app-specific-data-retrieval_2`) and `da:asdr`
   (using branch `feature/app-specific-data-retrieval`):

    $ export DOCKER_BUILDKIT = 1
    $ docker build --ssh default -t client:asdr --build-arg BRANCH=feature/app-specific-data-retrieval_2 -f images/client/Dockerfile images/client/

2. Run the services using `docker-compose.light-client.yml`:

    $ docker-compose -f docker-compose.light-client.yml up 

# Deploy Testnet with Ansible

## Requirements

  * Ansible ~> 5
  * 1password CLI tool https://1password.com/downloads/command-line/
  * AWS SSO access to Avail testnet account

## Provision instances

Ansible deployment use Docker containers to run the network, the instances are provisioned by Terraform and are ready to run the playbooks. Currently IPs are EIPs currently existing in the testnet account.

  1. Copy and paste AWS SSO environment variables for Programmatic access to your terminal
  2. Sign in to 1password `eval $(op signin)`
  3. Provision the cluster with `ansible-playbook site.yml --diff -v` from the ansible directory

# TestNet: Run A Validator

## Initial Set-up

If you want to run a validator, you will need the following requirements:

a. A Standard Hareward, which is:
  - CPU - Intel(R) Core(TM) i7-7700K CPU @ 4.20GHz
  - Storage - A NVMe solid state drive. Should be reasonably sized to deal with blockchain growth. Starting around 80GB - 160GB will be okay for the first six months.
  - Memory - 64GB ECC

b. At least, 1000 AVL to bound your validator.

## Build or Download the Data-Avail binary

See previous sections to know how to build or just use `0xpolygon/avail:latest` docker image.

## Synchronize Chain Data

You can begin syncing your node by running the following command:a

    $> data-avail --chain=misc/genesis/testnet.chain.spec.raw.json --pruning=archive

The `--pruning=archive` flag is implied by the `--validator` flag, so it is only required explicitly if you start your node without one of these two options. If you do not set your pruning to archive node, even when not running in validator mode, you will need to re-sync your database when you switch.


## Bond AVL

It is highly recommended that you make your controller and stash accounts be two separate accounts. For this, you will create two accounts and make sure each of them have at least enough funds to pay the fees for making transactions. Keep most of your funds in the stash account since it is meant to be the custodian of your staking funds.

Make sure not to bond all your AVL balance since you will be unable to pay transaction fees from your bonded balance.

It is now time to set up our validator. We will do the following:

 - Bond the AVL of the Stash account. These AVL will be put at stake for the security of the network and can be slashed.
 - Select the Controller. This is the account that will decide when to start or stop validating.

First, go to the `Developer` top menu, and click on `Extrinsics`. Select the `staking` pallet, and 
the `bond` extrinsic. Create a transaction where your `stash` account bounds `1001 AVLs` at least to
your `controller` account, as you can see in the picture:

![Add Validator: Bound funds](.web_resources/add_validator_bound_step.png?raw=true "Bound funds")


- **Stash** account - Select your Stash account. In this example, we will bond 1001 `AVL`s, where the minimum bonding amount is 1000. Make sure that your Stash account contains at least this much. You can, of course, stake more than this.
- **Controller** account - Select the Controller account created earlier. This account will also need a _small amount of AVL_ in order to start and stop validating.
- **Value** bonded - How much `AVL` from the Stash account you want to bond/stake. Note that you do not need to bond all of the `AVL` in that account. Also note that you can always bond more `AVL` later. However, withdrawing any bonded amount requires the duration of the unbonding period.
- **Payment** destination - The account where the rewards from validating are sent. More info [here](https://wiki.polkadot.network/docs/learn-staking#reward-distribution).

## Set Session Keys

Once your node is fully synced, stop the process by pressing `Ctrl-C`. At your terminal prompt, you will now start running the node.

### Generating the Session Keys

You need to tell the chain your Session keys by signing and submitting an extrinsic. This is what associates your validator node with your Controller account on Data-Avail.

#### Option 1: PolkadotJS-APPS

You can generate your [Session keys](https://wiki.polkadot.network/docs/learn-keys#session-keys) in the client via the apps RPC. If you are doing this, make sure that you have the PolkadotJS-Apps explorer attached to your validator node. You can configure the apps dashboard to connect to the endpoint of your validator in the Settings tab. If you are connected to a default endpoint hosted by Polygon, you will *not be able* to use this method since making RPC requests to this node would effect the local keystore hosted on a public node and you want to make sure you are interacting with the keystore for your node.

Once ensuring that you have connected to your node, the easiest way to set session keys for your node is by calling the `author_rotateKeys` RPC request to create new keys in your validator's keystore. Navigate to Toolbox tab and select RPC Calls then select the `author` > `rotateKeys()` option and remember to save the output that you get back for a later step.

#### Option 2: CLI

If you are on a **remote server**, it is easier to run this command on the same machine (while the node is running with the default HTTP RPC port configured):

    curl -H "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method": "author_rotateKeys", "params":[]}' http://localhost:9933

The output will have a hex-encoded "result" field. The result is the concatenation of the four public keys. Save this result for a later step.

You can restart your node at this point.

### Submitting the setKeys Transaction

You need to tell the chain your Session keys by signing and submitting an extrinsic. This is what associates your validator with your Controller account.

Go to `Staking` > `Account Actions`, and click "Set Session Key" on the bonding account you generated earlier. Enter the output `from author_rotateKeys` in the field and click "Set Session Key".


![Set Session Keys](.web_resources/add_validator_set_session_key.png?raw=true "Bound funds")


Submit this extrinsic, and you are now ready to start validating.

## Validate

To verify that your node is live and synchronized, head to `Network > Staking`, and section
`Waiting`. Your account should be shown there. A new validator set is selected every `Era`, based on
the staking amount.
