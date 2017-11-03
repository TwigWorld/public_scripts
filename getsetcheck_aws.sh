working_dir="$(dirname $(readlink -f "$0"))"
param_file="${working_dir}/params"
json_file="/tmp/getsetcheck_json_parameters"

source "$param_file"

check_set()
{
    key="$1"
    value="$(eval echo \$$key)"
    
    if [ -z "$value" ]; then
        echo "Error, environment variable '$key' not set!"
        exit 1
    fi 
}

set_ssm_param()
{
    key="$1"
    value="$(eval echo \$$key)"
    value_type=""

    if [ -z "$value" ]; then 

        if [ ! -e "$json_file" ]; then
	    json=$(aws --region eu-west-1 ssm get-parameters-by-path --path "$prefix" --with-decryption --output json)
	    jq ".Parameters[]" <<< $json >> "${json_file}"
	    next_token=$(jq --raw-output ".NextToken" <<< $json)
	    
	    while [ "$next_token" != 'null' ]; do
	        json=$(aws --region eu-west-1 ssm get-parameters-by-path --path "$prefix" --with-decryption --output json --next-token $next_token)
	        jq ".Parameters[]" <<< $json >> "${json_file}"
	        next_token=$(jq --raw-output ".NextToken" <<< $json)
	    done
        fi 

        json_value="$(jq "select(.Name==\"${prefix}${key}\") | .Value" <"${json_file}")"
        value_type="$(jq "select(.Name==\"${prefix}${key}\") | .Type" <"${json_file}" | sed 's/^"\|"$//g')"

        if [ "$json_value" == "null" ]; then
            echo "Could not get value for '${prefix}${key}'"
            exit 1
        fi 

        value=$(sed 's/^"\|"$//g' <<< $json_value)
    fi

    export "$key=$value"

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
    limit=20

    while ! nc -z "$host" "$port"; do
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

for var in $mandatory_param_array; do 
    check_set "$var"
    echo "$var='$(eval echo \$$var)'"
done 

for var in $optional_param_array; do
    set_ssm_param "$var"
done 

for var in $network_socket_array; do
    echo "Checking network for '$var'"
    check_network "$var"
done 
