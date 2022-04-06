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


## TestNet 

The TestNet is composed by the following services:
 - One `Hashicorp Vault` to manage controller and session keys. 
 - Three validators.
 - One full node synchronized with validators.
 - One HTTPS proxy with Explorer and WS access to the full node. 

## Step 1. Load TestNet Template

    ❯ monk load monk/polygon-da-testnet.matic.today.yaml 

## Step 2. Deploy Vault And Register Validators Keys

*NOTE:* The current `Vault` configuration is for `development` environment. 

    ❯ monk run polygon/da-vault

Open an interactive shell in the `Vault` container, and add the private keys for each validator:

    ❯ monk shell polygon/da-vault

    #> echo '{"name": "da-validator-1", "keynode": {"pk": "12D3KooWK1NcYjwpyRUYVG9tjp7X2iGbrQxNVafC5hJU9mggYTgv", "sk": "<key node private key>" }, "sk": "<controller private key>" }' | vault kv put -address=http://127.0.0.1:8200 -format=json secret/da/testnet/da-validator-1 -
    
    #> echo '{"name": "da-validator-2", "keynode": {"pk": "12D3KooWQtxig5HukFDwQzshGWgQEZAqGqdCN7AQBW7cQRJWCyxL", "sk": "<key node private key>" }, "sk": "<controller private key>" }' | vault kv put -address=http://127.0.0.1:8200 -format=json secret/da/testnet/da-validator-2 -

    #> echo '{"name": "da-validator-3", "keynode": {"pk": "12D3KooW9tVuCzq3eknsevL5uyqQ3LpVcuqtkTqropjNccbhsWBz", "sk": "<key node private key>" }, "sk": "<controller private key>" }' | vault kv put -address=http://127.0.0.1:8200 -format=json secret/da/testnet/da-validator-3 -

    #> exit

**Note:** The Json format is the following:

```Json
{
  "name": "da-validator-1",
  "keynode": {
    "pk": "12D3KooWK1NcYjwpyRUYVG9tjp7X2iGbrQxNVafC5hJU9mggYTgv",
    "sk": "...<key node private key>.."
  },
  "sk": "...<controller private key>..."
}
```

### Step 3. Run Validators

    ❯ monk run polygon/da-validator-1 polygon/da-validator-2 polygon/da-validator-3
    
### Step 4. Add Private Keys to Running Validators

Load private keys into validator nodes, using the `monk` action `load-keys`. 

    ❯ monk do polygon/da-validator-1/load-keys
    ❯ monk do polygon/da-validator-2/load-keys
    ❯ monk do polygon/da-validator-3/load-keys

### Step 5 (BUG) Restart Validator Nodes

**NOTE:**  Due to a current bug on *Substrate* version `polkadot-v0.9.13`, we need to restart all
nodes after insert the private keys.

    ❯ monk restart polygon/da-validator-1 polygon/da-validator-2 polygon/da-validator-3
