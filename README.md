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

1. Build images, `client:asdr`(usign branch `feature/app-specific-data-retrieval_2`) and `da:asdr`
   (using branch `feature/app-specific-data-retrieval`):

    $ export DOCKER_BUILDKIT = 1
    $ docker build --ssh default -t client:asdr --build-arg BRANCH=feature/app-specific-data-retrieval_2 -f images/client/Dockerfile images/client/
    ...
    $ docker build --ssh default -t da:asdr --build-arg BRANCH=feature/app-specific-data-retrieval -f images/da/Dockerfile images/da
    ...

2. Run the services using `docker-compose.light-client.yml`:

    $ docker-compose -f docker-compose.light-client.yml up 
    ...
