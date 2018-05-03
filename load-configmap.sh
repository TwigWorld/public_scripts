#!/bin/bash

set -e
working_dir="$(dirname $(readlink -f "$0"))"
SKIP_NETWORK_CHECKS=True
JSON_FILE=/tmp/getsetcheck_json_parameters

source "${working_dir}/getsetcheck_aws.sh"


