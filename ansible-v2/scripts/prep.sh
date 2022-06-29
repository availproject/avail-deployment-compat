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

while getopts d: flag
do
    case "$flag" in
        d) deployment_name=${OPTARG};;
    esac
done


if [ -z "$deployment_name" ]
then
    echo "Please use the -d switch to provide a deployment_name for setup"
    exit
fi

echo "Deployment name: $deployment_name";

echo $deployment_name > $tmp_dir/deployment_name.txt

if [ ! -d build ]
then
    mkdir build
fi

if [ -d build/$deployment_name ]
then
    echo "Ansibile deployment from $deployment_name has already be prepapred"
    exit
fi

mkdir build/$deployment_name

echo "Generating list of nodes based on the current ansible inventory"
ansible-inventory --list | jq '._meta.hostvars[] | {tag_name: .tags.Name, tag_role: .tags.Role, instance_id: .instance_id}'  | jq -s '.' > $tmp_dir/nodes.json
cat $tmp_dir/nodes.json | jq -r '.[].tag_name' > $tmp_dir/names.txt

echo "Adding wallets that aren't tied to physical hosts"

echo "election-01" >> $tmp_dir/names.txt
echo "sudo-01" >> $tmp_dir/names.txt
echo "tech-committee-01" >> $tmp_dir/names.txt
echo "tech-committee-02" >> $tmp_dir/names.txt
echo "tech-committee-03" >> $tmp_dir/names.txt


echo "Generating p2p keys and wallets for all nodes"
cat $tmp_dir/names.txt | while IFS= read -r node_name; do
    printf 'Generating keys for %s\n' "$node_name"
    docker run --platform linux/amd64 --entrypoint /da/bin/data-avail -v $tmp_dir:/out:rw 0xpolygon/avail:1.0.1 key generate --output-type json --scheme Sr25519 -w 21 > $tmp_dir/$node_name.wallet.sr25519.json
    cat $tmp_dir/$node_name.wallet.sr25519.json | jq -r '.secretPhrase' > $tmp_dir/$node_name.wallet.secret
    docker run --platform linux/amd64 --entrypoint /da/bin/data-avail -v $tmp_dir:/out:rw 0xpolygon/avail:1.0.1 key generate-node-key 2> $tmp_dir/$node_name.public.key 1> $tmp_dir/$node_name.private.key
    docker run --platform linux/amd64 --entrypoint /da/bin/data-avail -v $tmp_dir:/out:rw 0xpolygon/avail:1.0.1 key inspect --scheme Ed25519 --output-type json /out/$node_name.wallet.secret > $tmp_dir/$node_name.wallet.ed25519.json
done

./scripts/consolidate-keys.py $tmp_dir

op vault create "Avail Devnet: $deployment_name"
find $tmp_dir -type f -name '*.op.tpl.json' | xargs -I xxx op item create --vault "Avail Devnet: $deployment_name" --template=xxx

cp templates/genesis/devnet.template.json $tmp_dir
./scripts/update-dev-chainspec.py $tmp_dir

docker run --platform linux/amd64 --entrypoint /da/bin/data-avail -v $tmp_dir:/out:rw 0xpolygon/avail:1.0.1 build-spec --chain=/out/populated.devnet.chainspec.json --raw --disable-default-bootnode > $tmp_dir/populated.devnet.chainspec.raw.json

cp $tmp_dir/master.json build/$deployment_name/
cp $tmp_dir/populated.devnet.chainspec.* build/$deployment_name/
