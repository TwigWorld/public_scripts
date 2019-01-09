# This file should be sourced, not run directly

# Runtime flags
json_file="${JSON_FILE:-/tmp/getsetcheck_json_parameters}"
nc_timout="${NC_TIMEOUT:-5}"
network_check_limit="${NETWORK_CHECK_LIMIT:-20}"
skip_network_checks="${SKIP_NETWORK_CHECKS}"

if [[ "${ENABLE_AWS_PARAMSTORE:-True}" =~ ^[Tt]rue$ ]]; then
  enable_aws_paramstore=true
else
  enable_aws_paramstore=false
fi


echo "\$0=$0"
working_dir="$(dirname $(readlink -f "$0"))"
echo "working_dir=$working_dir"
param_file="${working_dir}/params"


test -e "$param_file" && source "$param_file"

check_set()
{
    key="$1"
    value="$(eval echo \$$key)"

    if [ -z "$value" ]; then
        echo "Error, environment variable '$key' not set!"
        exit 1
    fi
}

pull_aws_params()
{
    json=$(ssm-get-parameters-by-path --path "$prefix")
    jq ".Parameters[]" <<< $json >> "${json_file}"
    next_token=$(jq --raw-output ".NextToken" <<< $json)

    while [ "$next_token" != 'null' ]; do
        json=$(ssm-get-parameters-by-path --path "$prefix" --next-token $next_token)
        jq ".Parameters[]" <<< $json >> "${json_file}"
        next_token=$(jq --raw-output ".NextToken" <<< $json)
    done
}

set_ssm_param()
{
    key="$1"
    value="$(eval echo \$$key)"
    value_type=""

    if [ -z "$value" ]; then

        json_value="$(jq "select(.Name==\"${prefix}${key}\") | .Value" --raw-output <"${json_file}")"
        value_type="$(jq "select(.Name==\"${prefix}${key}\") | .Type" --raw-output <"${json_file}")"

        if [ -z "$json_value" ]; then
            echo "Could not get value for '${prefix}${key}'"
            exit 1
        fi

        value="$json_value"
    fi

    export $key="$value"

    if [ "$value_type" != 'SecureString' ]; then
        echo "$key=$value"
    else
        echo "$key=<Redacted>"
    fi
}

check_network()
{
    host_key="$(echo $1 | sed 's/:.*//g')"
    port_key="$(echo $1 | sed 's/.*://g')"

    check_set "$host_key"
    check_set "$port_key"

    host="$(eval echo \$$host_key)"
    port="$(eval echo \$$port_key)"

    count=0
    limit="$network_check_limit"

    while ! nc -z -w "$nc_timout" "$host" "$port"; do
        count=$((count + 1))
        if ((count >= limit)); then
            echo "Could not reach network resource '${host}:${port}'"
            exit 1
        fi
        echo "Waiting for network resource at '${host}:${port}'"
        echo "Attempt ${count}/${limit}"
        sleep 1
    done

    echo "Successfully reached '${host}:${port}'"
}

if [[ "$enable_aws_paramstore" == true ]]; then
  for var in $mandatory_param_array; do
      check_set "$var"
      echo "$var='$(eval echo \$$var)'"
  done
  if [ ! -e "$json_file" ]; then
      pull_aws_params
  fi
fi


for var in $optional_param_array; do
  if [[ "$enable_aws_paramstore" == true ]]; then
    set_ssm_param "$var"
  else
    check_set "$var"
  fi
done

if [[ -z $skip_network_checks ]]; then
    for var in $network_socket_array; do
        echo "Checking network for '$var'"
        check_network "$var"
    done
fi
