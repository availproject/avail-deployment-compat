# Data Availability Deployments 

## Current Testnet Deployment

| Name    | Node IP  | P2P Discovery Address | Running |
| ------  | ---- | --------------------- | ------- |
| Validator 1 | 54.160.87.220 |  | `cd da-deployment && docker-compose -f docker-compose.da-val-1.yml up -d`  |
| Validator 2 | 3.218.2.152  |  | `cd da-deployment && docker-compose -f docker-compose.da-val-2.yml up -d`  |
| Validator 3 | 3.230.45.76 |  | `cd da-deployment && docker-compose -f docker-compose.da-val-3.yml up -d`  |
| Full Node | https://polygon-da-explorer.matic.today/ |  | `cd da-deployment && docker-compose -f docker-compose.da-val-3.yml up -d`  |

## Custom 

Testnet is using the following chain spec file: [customSpec.json](./volume/stage/customSpec.json)

## Boot nodes

 - Validator 1: 
    /ip4/54.160.87.220/tcp/30333/p2p/12D3KooWK1NcYjwpyRUYVG9tjp7X2iGbrQxNVafC5hJU9mggYTgv

 - Validator 2:
    /ip4/3.218.2.152/tcp/30333/p2p/12D3KooWQtxig5HukFDwQzshGWgQEZAqGqdCN7AQBW7cQRJWCyxL

 - Validator 3:
    /ip4/3.230.45.76/tcp/30333/p2p/12D3KooW9tVuCzq3eknsevL5uyqQ3LpVcuqtkTqropjNccbhsWBz


# How to Build Data Availability

## Option A: Build a Docker image

The easiest way to build 

    $ docker-compose -f docker-compose.stage.yml build validator1


## Option B: Build from source code
1. Clone the repo and checkout the proper branch:

    $ git clone git@github.com:maticnetwork/substrate.git
    $ git checkout da-poc-upgrade-3.0

2. Build the node template binary

    $ cargo build --release -p node-template

3. _Optional_ If you want to run your node in the QA testnet you will need the customized chain spec
   file and add a bootstrap node

    $ ./target/release/node-template --chain  --bootnodes /ip4/54.160.87.220/tcp/30333/p2p/


### Extra - How to Generate Deterministic WASM

The `srtool` allows building WASM runtimes in a deterministic way, allowing CIs and users, with various machines and OS, to produce a strictly identical WASM runtime.

1. Install [srtool-cli](https://github.com/chevdor/srtool-cli)

2. Move to your `substrate` root folder and build the WASM runtime:

    $ srtool build -r ./bin/node-template/runtime/ --package node-template-runtime

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

## Build and Run Light Client and Data-Avail in Dev.

1. Build images, `client:asdr`(using branch `feature/app-specific-data-retrieval_2`) and `da:asdr`
   (using branch `feature/app-specific-data-retrieval`):

    $ export DOCKER_BUILDKIT = 1
    $ docker build --ssh default -t client:asdr --build-arg BRANCH=feature/app-specific-data-retrieval_2 -f images/client/Dockerfile images/client/

2. Run the services using `docker-compose.light-client.yml`:

    $ docker-compose -f docker-compose.light-client.yml up 

# Using Monk Templates

## DevNet using 3 validators
In the `DevNet`, validators use the development accounts: `Alice`, `Bob`, and `Charlie`. 

### Step 1: Build Images

    export DOCKER_BUILDKIT=1
    docker build -t da:ava-33  --build-arg BRANCH=miguel/ava-33-create-monk-template-for-da-testnet -f images/da/Dockerfile images/da/    

### Step 2. Load Monk Templates

The DevNet only need to load 2 monk templates:

- `monk/polygon-da-base.matic.today.yaml`, which contains common definition for DevNet & TestNet.
- `monk/polygon-da-devnet.matic.today.yaml`, where validators are defined.

```
    monk s ns-delete /templates/local/polygon
    monk load monk/polygon-da-base.matic.today.yaml
    monk load monk/polygon-da-devnet.matic.today.yaml
```
```


### Step 3. Run templates

Once templates are loaded, we only need to run 3 nodes.

    ❯ monk run polygon/da-dev-validator-1 polygon/da-dev-validator-2 polygon/da-dev-validator-3


Now you can check logs using `monk logs`, i.e.:

    ❯ monk logs -f -l 100 polygon/da-dev-validator-1
    
    2022-03-22 10:52:20 ✨ Imported #9 (0x911b…bdf5)    
    2022-03-22 10:52:23 💤 Idle (2 peers), best: #9 (0x911b…bdf5), finalized #7 (0x6309…0366), ⬇ 1.5kiB/s ⬆ 1.8kiB/s    
    2022-03-22 10:52:28 💤 Idle (2 peers), best: #9 (0x911b…bdf5), finalized #7 (0x6309…0366), ⬇ 1.2kiB/s ⬆ 1.2kiB/s    
    2022-03-22 10:52:33 💤 Idle (2 peers), best: #9 (0x911b…bdf5), finalized #7 (0x6309…0366), ⬇ 1.2kiB/s ⬆ 1.2kiB/s    
    2022-03-22 10:52:38 💤 Idle (2 peers), best: #9 (0x911b…bdf5), finalized #7 (0x6309…0366), ⬇ 1.1kiB/s ⬆ 1.1kiB/s    
    2022-03-22 10:52:40 Rows: 1 Cols: 4 Size: 128    
    2022-03-22 10:52:40 Time to extend block 150.509µs    
    2022-03-22 10:52:40 Time to prepare 181.938µs    
    2022-03-22 10:52:40 Number of CPU cores: 16    
    2022-03-22 10:52:40 Time to build a commitment 1.766672ms    
    2022-03-22 10:52:40 ✨ Imported #10 (0x64f4…84b5)    
    2022-03-22 10:52:43 💤 Idle (2 peers), best: #10 (0x64f4…84b5), finalized #8 (0x3c88…cfe1), ⬇ 1.6kiB/s ⬆ 1.6kiB/s    
    2022-03-22 10:52:48 💤 Idle (2 peers), best: #10 (0x64f4…84b5), finalized #8 (0x3c88…cfe1), ⬇ 1.1kiB/s ⬆ 1.1kiB/s    
    2022-03-22 10:52:53 💤 Idle (2 peers), best: #10 (0x64f4…84b5), finalized #8 (0x3c88…cfe1), ⬇ 1.2kiB/s ⬆ 1.2kiB/s    
    2022-03-22 10:52:58 💤 Idle (2 peers), best: #10 (0x64f4…84b5), finalized #8 (0x3c88…cfe1), ⬇ 1.2kiB/s ⬆ 1.2kiB/s    
    2022-03-22 10:53:00 Rows: 1 Cols: 4 Size: 128    
    2022-03-22 10:53:00 Time to extend block 146.593µs    
    2022-03-22 10:53:00 Time to prepare 175.756µs    
    2022-03-22 10:53:00 Number of CPU cores: 16    
    2022-03-22 10:53:00 Time to build a commitment 1.891133ms    
    2022-03-22 10:53:00 ✨ Imported #11 (0x0a5e…43d6)

### Purge Node State

In this configuration, the state of the node is stored at `/var/lib/monkd/volumes/dev/validator`, so
you can remove these folders or just use `monk purge`:

    ❯ monk purge polygon/da-dev-validator-1 polygon/da-dev-validator-2 polygon/da-dev-validator-3


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
