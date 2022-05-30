#!/bin/bash
cat /da/bin/da.sh ;
/da/bin/data-avail \
	--validator \
	--chain /da/genesis/testnet-v2.chain.spec.raw.json \
	--base-path /da/state \
	--name {{ node_name }} \
	--node-key {{ node_key }} \
	--keystore-path /da/keystore \
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
	{% for rn in node_reserved_nodes %}
	--reserved-nodes {{ rn }} \
	{% endfor %}
	{% for bn in node_boot_nodes %}
	--bootnodes {{ bn }} \
	{% endfor %}

	-lruntime::system=trace \
	2>&1

