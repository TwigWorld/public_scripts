#!/bin/bash

json="$(jq --compact-output '.' </dev/stdin)"
IFS=$'\n'
json_array=($json)


for item in "${json_array[@]}"; do 
    json_name="$(jq '.Name' <<< "$item")"
    json_value="$(jq '.Value' <<< "$item")"
    json_type="$(jq '.Type' <<< "$item")"
#    aws ssm put-parameter --name "$json_name" --value "$json_value" --type "$json_type" --overwrite
    aws ssm put-parameter --cli-input-json "{ \"Name\": $json_name, \"Value\": $json_value, \"Type\": $json_type }" --overwrite
done 
