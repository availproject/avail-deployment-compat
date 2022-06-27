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

/da/bin/data-avail \
    {%  if is_validator %}
    --validator \
    {% endif %}
    --public-addr /dns/{{ lb_dns }}/tcp/{{ node_port }}/p2p/{{ p2p_pub_key }} \
    {%  for item in hostvars %}{% if (hostvars[item].tags.Role == "validator" or hostvars[item].tags.Role == "full-node" and item != inventory_hostname) %}
    --reserved-nodes /dns/{{ lb_dns }}/tcp/{{ hostvars[item].tags.AvailPort }}/p2p/{{ lookup('op', 'Wallet Credentials for ' + hostvars[item].tags.Name, vault='Avail Devnet: ' + lineage, field='libP2PPub') | trim }}\
    {% endif %}{% endfor %}
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
    {%  if not is_validator %}
    --rpc-methods Safe \
    --rpc-cors all \
    --unsafe-rpc-external \
    --unsafe-ws-external \
    {% endif %}

    2>&1

