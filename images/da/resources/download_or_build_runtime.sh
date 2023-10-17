#!/bin/bash

# Check if the binary version is provided as an argument
if [ $# -lt 1 ]; then
    echo "Usage: $0 <binary_version> [features]"
    exit 1
fi


binary_version="$1"
binary_url="https://github.com/availproject/avail/releases/download/$binary_version/data-avail-runtime.compact.compressed.wasm"


binary_file="runtime.wasm"

# Try to fetch the binary with wget
wget -O "$binary_file" "$binary_url"

# Check the exit status of wget
if [ $? -eq 0 ]; then
    echo "Binary ($binary_version) successfully fetched."
    mkdir -p target/release/wbuild/da-runtime
    mv runtime.wasm target/release/wbuild/da-runtime/da_runtime.compact.compressed.wasm 
else
    echo "Building from source!"
    cargo build --release -p data-avail --features "$2" --jobs 2
fi
