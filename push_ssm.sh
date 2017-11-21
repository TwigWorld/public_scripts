#!/bin/bash

json="$(jq --compact-output '.' </dev/stdin)"
IFS=$'\n'
json_array=($json)


for item in "${json_array[@]}"; do 
    json_name="$(jq --raw-output '.Name' <<< "$item")"
    json_value="$(jq --raw-output '.Value' <<< "$item")"
    json_type="$(jq --raw-output '.Type' <<< "$item")"
    aws ssm put-parameter --name "$json_name" --value "$json_value" --type "$json_type" --overwrite
done 
