#!/bin/bash
# --validator \
cat /da/bin/da.sh ;
/da/bin/data-avail \
	--chain /da/genesis/testnet-v2.chain.spec.raw.json \
	--base-path /da/state \
	--pruning archive \
	--sync Full \
	--name {{ node_name }} \
	--node-key {{ node_key }} \
	--execution NativeElseWasm \
	--ws-max-connections {{ node.ws_max_connections }} \
	--in-peers  {{ node.in_peers }} \
	--out-peers {{ node.out_peers }} \
	--port {{ node_port }} \
	--prometheus-port {{ prometheus.port }} \
	--prometheus-external \
	--ws-port {{ node_ws_port }} \
	--ws-external \
	--rpc-port {{ node_rpc_port }} \
	--rpc-cors all \
	--rpc-external \
{% for bn in node.boot_nodes %}
	--bootnodes {{ bn }} \
{% endfor %}
2>&1

