#!/bin/bash

# Check if the binary version is provided as an argument
if [ $# -lt 1 ]; then
    echo "Usage: $0 <binary_version> [features]"
    exit 1
fi


binary_version="$1"
binary_url="https://github.com/availproject/avail/releases/download/$binary_version/data-avail-debian-12-amd64.tar.gz"


binary_file="release.tar.gz"

# Try to fetch the binary with wget
wget -O "$binary_file" "$binary_url"

# Check the exit status of wget
if [ $? -eq 0 ]; then
    echo "Binary ($binary_version) successfully fetched."
    mkdir -p target/release
    tar -xzf "$binary_file" -C target/release
    mv target/release/data-avail-debian-12-amd64 target/release/data-avail
else
    echo "Building from source!"
    cargo build --release -p data-avail --features "$2"
fi
