#!/bin/bash

set -euo pipefail

install_version() {
  echo "Installing kubectl-${kubectl_version}" >&2

  mkdir -p "${HOME}/.local/bin/"

  curl -o "${HOME}/.local/bin/kubectl-${kubectl_version}" -LO https://storage.googleapis.com/kubernetes-release/release/${kubectl_version}/bin/linux/amd64/kubectl
  chmod +x "${HOME}/.local/bin/kubectl-${kubectl_version}"
}

kubectl_version="${KUBECTL_VERSION:-$(\
  ${HOME}/.local/bin/kubectl-v1.10.0 version --output json | jq '.serverVersion.gitVersion' --raw-output | grep -Eo '^v([0-9]+\.){2}[0-9]+')}"

if [[ ! -x "${HOME}/.local/bin/kubectl-${kubectl_version}" ]]; then
  install_version
fi

"${HOME}/.local/bin/kubectl-${kubectl_version}" $@
