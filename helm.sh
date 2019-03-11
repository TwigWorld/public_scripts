#!/bin/bash

set -e

helm_version="$(\
  kubectl get pod --all-namespaces -l app=helm,name=tiller -o json | \
  jq '.items[0].spec.containers[].image' --raw-output | \
  head -n 1 | grep -Eo ':[^:]+$' | tr -d ':')"

if [[ ! -x "${HOME}/.local/bin/helm-${helm_version}" ]]; then

  echo "Installing helm-${helm_version}" >&2

  mkdir -p "/tmp/helm-${helm_version}"
  mkdir -p "${HOME}/.local/bin/"

  curl --silent https://kubernetes-helm.storage.googleapis.com/helm-${helm_version}-linux-amd64.tar.gz \
    --output /tmp/helm-${helm_version}/helm-${helm_version}-linux-amd64.tar.gz

  tar --overwrite -C /tmp/helm-${helm_version} -xf /tmp/helm-${helm_version}/helm-${helm_version}-linux-amd64.tar.gz
  chmod +x /tmp/helm-${helm_version}/linux-amd64/helm
  mv /tmp/helm-${helm_version}/linux-amd64/helm "${HOME}/.local/bin/helm-${helm_version}"
fi

"${HOME}/.local/bin/helm-${helm_version}" $@
