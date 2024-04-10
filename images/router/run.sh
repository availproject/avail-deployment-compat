#!/bin/sh

set -ex

if [ -z "$DELAY_MS" ]; then
  echo "Error: DELAY_MS is not set!"
  exit 1
fi

ADDR_EXTERNAL=$(ip -json addr show eth0 | jq '.[0].addr_info[0].local' -r)
SUBNET_INTERNAL=$(ip -json addr show eth1 | jq '.[0].addr_info[0].local + "/" + (.[0].addr_info[0].prefixlen | tostring)' -r)

# Set up NAT
nft add table ip nat
nft add chain ip nat postrouting { type nat hook postrouting priority 100 \; }
nft add rule ip nat postrouting ip saddr $SUBNET_INTERNAL oifname "eth0" snat $ADDR_EXTERNAL

echo "1" > /tmp/setup_done # This will be checked by our docker HEALTHCHECK

tail -f /dev/null # Keep it running forever.
