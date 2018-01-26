# public_scripts

Theses scripts are publically accessible; so don't put any company information in them.

## getsetcheck_aws.sh

This script is used to fetch environment variables for docker containers. It should be sourced by the entrypoint before starting the application.

### Params

It expects to find a file called /params with the following variables:

| Variable | Description |
| -------- | ----------- |
| `mandatory_param_array` | Space delimited list of variables that must be pre-defined |
| `network_socket_array` | Space delimeted list of variables that compose a network socket that will be tested for connectivity. Must be in the format `host:port` |
| `optional_param_array` | Space delimited list of variables that will be fetched from AWS parameter store if not defined` |
| `prefix` | Key prefix to used when fetching values from AWS parameter store |

### Flags

The following flags can be defined:

| Flag | Default | Description |
| ---- | ------- | ----------- |
| `ENABLE_AWS_PULL` | True | Toggles whether the script pulls variables from AWS parameter store. When deploying to Kubernetes, you probably don't want the container to check AWS |
| `NC_TIMEOUT` | 5 | How long to wait for NC to check a network socket |
| `NETWORK_CHECK_LIMIT` | 20 | The number of times a network socket should be checked before being marked a failure |
| `SKIP_NETWORK_CHECKS` | \<undefined\> | If defined, will skip the checks defined in `network_socket_array` |
