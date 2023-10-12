#!/bin/bash

# Check if four arguments are provided
if [ $# -ne 4 ]; then
    echo "Usage: $0 <keyword> <keyword_file> <replacement_file> <output_file>"
    exit 1
fi

keyword="$1"
keyword_file="$2"
replacement_file="$3"
output_file="$4"

# Check if the keyword file exists
if [ ! -f "$keyword_file" ]; then
    echo "Keyword file '$keyword_file' does not exist."
    exit 1
fi

# Check if the replacement file exists
if [ ! -f "$replacement_file" ]; then
    echo "Replacement file '$replacement_file' does not exist."
    exit 1
fi

# Read the entire replacement file content once
replacement_content=$(<"$replacement_file")

# Process the keyword file line by line and replace the keyword
while IFS= read -r line; do
    replaced_line="${line//$keyword/$replacement_content}"
    echo "$replaced_line" >> "$output_file"
done < "$keyword_file"

echo "Replacement completed. Result saved in '$output_file'."
