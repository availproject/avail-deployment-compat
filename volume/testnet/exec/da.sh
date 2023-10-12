#!/bin/sh
cat /da/exec/da.sh

trap cleanup 1 2 3 6

cleanup()
{
  echo "Done cleanup ... quitting."
  exit 1
}


/da/bin/data-avail key insert --chain=/da/genesis/testnet-v2-local.chain.spec.raw.json --base-path=/da/state/ --keystore-path=/da/keystore/ --key-type=babe --scheme=Sr25519 --suri=/da/suri.txt
/da/bin/data-avail key insert --chain=/da/genesis/testnet-v2-local.chain.spec.raw.json --base-path=/da/state/ --keystore-path=/da/keystore/ --key-type=gran --scheme=Ed25519 --suri=/da/suri.txt
/da/bin/data-avail key insert --chain=/da/genesis/testnet-v2-local.chain.spec.raw.json --base-path=/da/state/ --keystore-path=/da/keystore/ --key-type=imon --scheme=Sr25519 --suri=/da/suri.txt
/da/bin/data-avail key insert --chain=/da/genesis/testnet-v2-local.chain.spec.raw.json --base-path=/da/state/ --keystore-path=/da/keystore/ --key-type=audi --scheme=Sr25519 --suri=/da/suri.txt
/da/bin/data-avail key insert --chain=/da/genesis/testnet-v2-local.chain.spec.raw.json --base-path=/da/state/ --keystore-path=/da/keystore/ --key-type=auth --scheme=Sr25519 --suri=/da/suri.txt

echo "$@"

/da/bin/data-avail $@




