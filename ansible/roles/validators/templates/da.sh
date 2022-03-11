#!/bin/bash
cat /da/bin/da.sh ;
/da/bin/data-avail \
	--validator \
	--chain /da/genesis/testnet.chain.spec.raw.json \
	--base-path /da/state \
	--name {{ id }} \
	--node-key {{ secret.json.data.data.keynode.sk }} \
	--keystore-path /da/keystore \
	--execution NativeElseWasm \
	--offchain-worker Always \
	--enable-offchain-indexing=true \
	--in-peers 50 \
	--out-peers 50 \
	--prometheus-port {{ prometheus.port }} \
	--prometheus-external \
	--port {{ port }} \
 	--bootnodes /ip4/52.47.205.129/tcp/30333/p2p/12D3KooW9tVuCzq3eknsevL5uyqQ3LpVcuqtkTqropjNccbhsWBz \
	--bootnodes /ip4/15.237.127.118/tcp/30333/p2p/12D3KooWQtxig5HukFDwQzshGWgQEZAqGqdCN7AQBW7cQRJWCyxL \
 	--bootnodes /ip4/52.47.205.129/tcp/30333/p2p/12D3KooW9tVuCzq3eknsevL5uyqQ3LpVcuqtkTqropjNccbhsWBz \
	2>&1
