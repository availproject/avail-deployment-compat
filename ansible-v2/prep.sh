#!/bin/bash

echo "Beginning ansible prep"

if ! command -v jq &> /dev/null
then
    echo "jq could not be found"
    exit
fi

if ! command -v op &> /dev/null
then
    echo "1password cli could not be found"
    exit
fi

if ! command -v docker &> /dev/null
then
    echo "docker could not be found"
    exit
fi

echo "Creating temp directory to house files"
tmp_dir=$(mktemp -d)

printf "The following directory was created %s\n" $tmp_dir

echo "Generating list of nodes based on the current ansible inventory"
ansible-inventory --list | jq '._meta.hostvars[] | {tag_name: .tags.Name, tag_role: .tags.Role, instance_id: .instance_id}'  | jq -s '.' > $tmp_dir/nodes.json

echo "Generating p2p keys and wallets for all nodes"
cat nodes.json | jq -r '.[].tag_name' | while IFS= read -r node_name; do
    printf 'Generating keys for %s\n' "$node_name"
    docker run --platform linux/amd64 --entrypoint /da/bin/data-avail -v $tmp_dir:/out:rw 0xpolygon/avail:1.0.1 key generate --output-type json --scheme Sr25519 -w 21 > $tmp_dir/$node_name.wallet.sr25519.json
    cat $tmp_dir/$node_name.wallet.sr25519.json | jq -r '.secretPhrase' > $tmp_dir/$node_name.wallet.secret
    docker run --platform linux/amd64 --entrypoint /da/bin/data-avail -v $tmp_dir:/out:rw 0xpolygon/avail:1.0.1 key generate-node-key 2> $tmp_dir/$node_name.public.key 1> $tmp_dir/$node_name.private.key
    docker run --platform linux/amd64 --entrypoint /da/bin/data-avail -v $tmp_dir:/out:rw 0xpolygon/avail:1.0.1 key inspect --scheme Ed25519 --output-type json /out/$node_name.wallet.secret > $tmp_dir/$node_name.wallet.ed25519.json
done

./combine.py $tmp_dir

# TODO should I verify that each item doesn't already exist?
find $tmp_dir -type f -name '*.op.tpl.json' | xargs -I xxx op item create --vault "Avail Devnet" --template=xxx

