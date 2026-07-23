#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ARGOCD_CONTEXT="${ARGOCD_CONTEXT:-kubernetes-admin@kubernetes}"
ARGOCD_CLEANUP_TIMEOUT="${ARGOCD_CLEANUP_TIMEOUT:-600}"

destroy_layer() {
  local layer="$1"

  echo
  echo "================================="
  echo " Destroying ${layer}"
  echo "================================="

  (
    cd "${ROOT_DIR}/${layer}"
    terraform init -input=false
    terraform destroy -input=false -auto-approve
  )
}

cleanup_argocd_applications() {
  local application
  local applications=()

  echo
  echo "Stopping sync and waiting for ArgoCD Applications to be deleted..."

  mapfile -t applications < <(
    kubectl \
      --context "${ARGOCD_CONTEXT}" \
      --namespace argocd \
      get applications.argoproj.io \
      -o name |
      grep -E -- '-(monitoring-stack|postgres-gateway|ops|jit-hub-app)$'
  )

  ((${#applications[@]} > 0)) || return 0

  for application in "${applications[@]}"; do
    kubectl \
      --context "${ARGOCD_CONTEXT}" \
      --namespace argocd \
      patch "${application}" \
      --type merge \
      --patch '{"operation":null,"spec":{"syncPolicy":{"automated":{"enabled":false}}}}' \
      >/dev/null
  done

  kubectl \
    --context "${ARGOCD_CONTEXT}" \
    --namespace argocd \
    wait --for=delete \
    "${applications[@]}" \
    --timeout="${ARGOCD_CLEANUP_TIMEOUT}s"
}

echo "================================="
echo " On-prem Terraform destroy start"
echo "================================="

destroy_layer "02-onprem-workloads"
cleanup_argocd_applications
destroy_layer "01-onprem-platform"

echo
echo "================================="
echo " On-prem Terraform destroy complete"
echo "================================="
