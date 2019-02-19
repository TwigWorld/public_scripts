#!/bin/bash
set -euo pipefail

releases=$(helm list --short --all)


orphans=($(grep -Fxv -f <(echo "${releases}") <(kubectl get all --all-namespaces -o json | jq '.items[].metadata.labels.release' --raw-output | sed '/null/d') | sort | uniq))

for orphan in "${orphans[@]}"; do
  kubectl get all -l release="$orphan" --no-headers --all-namespaces | awk '{ print $1 "	" $2 }'
done
