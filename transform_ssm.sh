#!/bin/bash

original_prefix="$1"
new_prefix="$2"

usage() { 
    echo "Usage: <json> | $0 <original_prefix> <new_name>" 
}

if [[ -z "$original_prefix" ]]; then
    usage
    exit 1
fi

if [[ -z "$new_prefix" ]]; then
    usage
    exit 1
fi 

json="$(jq --compact-output '.' </dev/stdin)"
IFS=$'\n'
json_array=($json)

for item in "${json_array[@]}"; do
    name="$(jq --raw-output '.Name' <<< "$item")"
    new_name=$(sed "s#^$original_prefix#$new_prefix#g" <<< "$name")
    jq --compact-output ".Name |= \"$new_name\"" <<< $item 
done
