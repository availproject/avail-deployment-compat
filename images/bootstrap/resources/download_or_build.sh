#!/bin/bash

# Check if the binary version is provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <binary_version>"
    exit 1
fi

binary_version="$1"
binary_url="https://github.com/availproject/avail-light-bootstrap/releases/download/$binary_version/avail-light-bootstrap-linux-amd64.tar.gz"


binary_file="release.tar.gz"

# Try to fetch the binary with wget
wget -O "$binary_file" "$binary_url"

# Check the exit status of wget
if [ $? -eq 0 ]; then
    echo "Binary ($binary_version) successfully fetched."
    mkdir -p target/release
    tar -xzf "$binary_file" -C target/release
    mv target/release/avail-light-bootstrap-linux-amd64 target/release/avail-light-bootstrap
else
    echo "Building from source!"
    cargo build --release -p  avail-light-bootstrap
fi
