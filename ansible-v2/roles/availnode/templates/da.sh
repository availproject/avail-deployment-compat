#!/bin/bash
cat /var/avail/da.sh ;

if [ ! -e /var/avail/babe.created ];
then
    /da/bin/data-avail key insert --chain=/var/avail/genesis/devnet.chain.spec.raw.json --base-path=/var/avail/state --keystore-path=/var/avail/keystore --suri=/var/avail/secret.txt --key-type=babe --scheme=Sr25519
    touch /var/avail/babe.created
fi

if [ ! -e /var/avail/gran.created ];
then
    /da/bin/data-avail key insert --chain=/var/avail/genesis/devnet.chain.spec.raw.json --base-path=/var/avail/state --keystore-path=/var/avail/keystore --suri=/var/avail/secret.txt --key-type=gran --scheme=Ed25519
    touch /var/avail/gran.created
fi

if [ ! -e /var/avail/imon.created ];
then
    /da/bin/data-avail key insert --chain=/var/avail/genesis/devnet.chain.spec.raw.json --base-path=/var/avail/state --keystore-path=/var/avail/keystore --suri=/var/avail/secret.txt --key-type=imon --scheme=Sr25519
    touch /var/avail/imon.created
fi

if [ ! -e /var/avail/audi.created ];
then
    /da/bin/data-avail key insert --chain=/var/avail/genesis/devnet.chain.spec.raw.json --base-path=/var/avail/state --keystore-path=/var/avail/keystore --suri=/var/avail/secret.txt --key-type=audi --scheme=Sr25519
    touch /var/avail/audi.created
fi

if [ ! -e /var/avail/authi.created ];
then
    /da/bin/data-avail key insert --chain=/var/avail/genesis/devnet.chain.spec.raw.json --base-path=/var/avail/state --keystore-path=/var/avail/keystore --suri=/var/avail/secret.txt --key-type=auth --scheme=Sr25519
    touch /var/avail/auth.created
fi

#TODO add the bootnodes / peers
#TODO --reserved-only for validators

/da/bin/data-avail \
    {%  if is_validator %}
    --validator \
    {% endif %}
    --chain /var/avail/genesis/devnet.chain.spec.raw.json \
    --base-path /var/avail/state \
    --name {{ node_name }} \
    --node-key-file /var/avail/nodeprivkey.txt \
    --keystore-path /var/avail/keystore \
    --execution NativeElseWasm \
    --offchain-worker Always \
    --enable-offchain-indexing=true \
    --in-peers 20 \
    --out-peers 20 \
    --prometheus-port {{ prometheus.port }} \
    --prometheus-external \
    --port {{ node_port }} \
    --ws-port {{ node_ws_port }} \
    --rpc-port {{ node_rpc_port }} \
    2>&1

