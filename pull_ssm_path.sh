#!/bin/bash

prefix="$1"

if [[ -z "$prefix" ]]; then
    echo "Usage: $0 <prefix>"
    exit 1
fi

json=$(aws --region eu-west-1 ssm get-parameters-by-path --recursive --path "$prefix" --with-decryption --output json)
jq -r --compact-output ".Parameters[]" <<< $json
next_token=$(jq --raw-output ".NextToken" <<< $json)

while [ "$next_token" != 'null' ]; do
    json=$(aws --region eu-west-1 ssm get-parameters-by-path --recursive --path "$prefix" --with-decryption --output json --next-token $next_token)
    jq -r --compact-output ".Parameters[]" <<< $json
    next_token=$(jq --raw-output ".NextToken" <<< $json)
done
