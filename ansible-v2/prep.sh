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

aws ssm get-parameter --name terraform-lineage | jq -r '.Parameter.Value' > $tmp_dir/lineage.id.txt
if [ ! -s $tmp_dir/lineage.id.txt ] ;
then
    echo "There was an issue finding the lineage id from AWS SSM"
    exit;
fi

lineage_id=$(cat $tmp_dir/lineage.id.txt)

echo "Current lineage id" $lineage_id

if [ ! -d build ]
then
    mkdir build
fi

if [ -d build/$lineage_id ]
then
    echo "Ansibile deployment from $lineage_id has already be prepapred"
    exit
fi

mkdir build/$lineage_id

echo "Generating list of nodes based on the current ansible inventory"
ansible-inventory --list | jq '._meta.hostvars[] | {tag_name: .tags.Name, tag_role: .tags.Role, instance_id: .instance_id}'  | jq -s '.' > $tmp_dir/nodes.json
cat nodes.json | jq -r '.[].tag_name' > $tmp_dir/names.txt

echo "Adding wallets that aren't tied to physical hosts"

echo "election_01" >> $tmp_dir/names.txt
echo "sudo_01" >> $tmp_dir/names.txt
echo "tech_committee_01" >> $tmp_dir/names.txt
echo "tech_committee_02" >> $tmp_dir/names.txt
echo "tech_committee_03" >> $tmp_dir/names.txt


echo "Generating p2p keys and wallets for all nodes"
cat $tmp_dir/names.txt | while IFS= read -r node_name; do
    printf 'Generating keys for %s\n' "$node_name"
    docker run --platform linux/amd64 --entrypoint /da/bin/data-avail -v $tmp_dir:/out:rw 0xpolygon/avail:1.0.1 key generate --output-type json --scheme Sr25519 -w 21 > $tmp_dir/$node_name.wallet.sr25519.json
    cat $tmp_dir/$node_name.wallet.sr25519.json | jq -r '.secretPhrase' > $tmp_dir/$node_name.wallet.secret
    docker run --platform linux/amd64 --entrypoint /da/bin/data-avail -v $tmp_dir:/out:rw 0xpolygon/avail:1.0.1 key generate-node-key 2> $tmp_dir/$node_name.public.key 1> $tmp_dir/$node_name.private.key
    docker run --platform linux/amd64 --entrypoint /da/bin/data-avail -v $tmp_dir:/out:rw 0xpolygon/avail:1.0.1 key inspect --scheme Ed25519 --output-type json /out/$node_name.wallet.secret > $tmp_dir/$node_name.wallet.ed25519.json
done

./scripts/consolidate-keys.py $tmp_dir

op vault create "Avail Devnet: $lineage_id"
find $tmp_dir -type f -name '*.op.tpl.json' | xargs -I xxx op item create --vault "Avail Devnet: $lineage_id" --template=xxx

cp templates/genesis/devnet.template.json $tmp_dir
./scripts/update-dev-chainspec.py $tmp_dir

docker run --platform linux/amd64 --entrypoint /da/bin/data-avail -v $tmp_dir:/out:rw 0xpolygon/avail:1.0.1 build-spec --chain=/out/populated.devnet.chainspec.json --raw --disable-default-bootnode > $tmp_dir/populated.devnet.chainspec.raw.json

cp $tmp_dir/master.json build/$lineage_id/
cp $tmp_dir/populated.devnet.chainspec.* build/$lineage_id/
