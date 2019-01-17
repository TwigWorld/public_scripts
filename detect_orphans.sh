#!/bin/bash
set -euo pipefail



releases=$(helm list --short --all)


orphans=($(grep -Fxv -f <(echo "${releases}") <(kubectl get all --all-namespaces -o json | jq '.items[].metadata.labels.release' --raw-output | sed '/null/d') | sort | uniq))
pvc_orphans=($(grep -Fxv -f <(echo "${releases}") <(kubectl get pvc --all-namespaces -o json | jq '.items[].metadata.labels.release' --raw-output | sed '/null/d') | sort | uniq))


for orphan in "${orphans[@]}"; do
  kubectl get all -l release="$orphan" --no-headers --all-namespaces | awk '{ print $1 "	" $2 }'
done

#for orphan in "${pvc_orphans[@]}"; do
#  kubectl get pvc -l release="$orphan" --no-headers --all-namespaces | awk '{ print $1 "	" $2 }'
#  #kubectl delete pvc -n ci -l release="$orphan"
#done
