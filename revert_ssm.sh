#!/bin/bash

set -euo pipefail

json="$(jq --compact-output '.' </dev/stdin)"
IFS=$'\n'
json_array=($json)


for item in "${json_array[@]}"; do 
    json_name="$(jq '.Name' -r <<< "$item")"
    json_value="$(jq '.Value' <<< "$item")"
    json_type="$(jq '.Type' <<< "$item")"
    json_version="$(jq '.Version' <<< "$item")"
#    echo "'$item'"

#    aws ssm get-parameter --name "${json_name}:5"

    aws ssm get-parameter --cli-input-json "{ \"Name\": \"${json_name}:$((json_version - 1))\" }" --with-decryption | jq '.Parameter' --compact-output 
done 
