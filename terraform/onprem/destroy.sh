#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ARGOCD_CONTEXT="${ARGOCD_CONTEXT:-kubernetes-admin@kubernetes}"
ARGOCD_CLEANUP_TIMEOUT="${ARGOCD_CLEANUP_TIMEOUT:-600}"
ARGOCD_CLEANUP_POLL_INTERVAL="${ARGOCD_CLEANUP_POLL_INTERVAL:-5}"

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

get_pending_argocd_applications() {
  kubectl \
    --context "${ARGOCD_CONTEXT}" \
    --namespace argocd \
    get applications.argoproj.io \
    -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{range .metadata.ownerReferences[*]}{.name}{" "}{end}{"\n"}{end}' |
    awk '
      $0 ~ /(^|[[:space:]])(jit-hub-infra-appset|jit-hub-app-appset)([[:space:]]|$)/ ||
      $1 ~ /-(monitoring-stack|postgres-gateway|ops|jit-hub-app)$/ {
        print $1
      }
    '
}

wait_for_argocd_cleanup() {
  local deadline
  local pending_applications

  if [[ ! "${ARGOCD_CLEANUP_TIMEOUT}" =~ ^[1-9][0-9]*$ ]]; then
    echo "ERROR: ARGOCD_CLEANUP_TIMEOUT must be a positive integer." >&2
    return 1
  fi

  if [[ ! "${ARGOCD_CLEANUP_POLL_INTERVAL}" =~ ^[1-9][0-9]*$ ]]; then
    echo "ERROR: ARGOCD_CLEANUP_POLL_INTERVAL must be a positive integer." >&2
    return 1
  fi

  echo
  echo "Waiting for ArgoCD-managed workloads (including monitoring) to be deleted..."

  deadline=$((SECONDS + ARGOCD_CLEANUP_TIMEOUT))

  while true; do
    if ! pending_applications="$(get_pending_argocd_applications)"; then
      echo "ERROR: Failed to check ArgoCD Application cleanup status." >&2
      return 1
    fi

    if [[ -z "${pending_applications}" ]]; then
      echo "ArgoCD-managed workload cleanup complete."
      return 0
    fi

    if (( SECONDS >= deadline )); then
      echo "ERROR: Timed out waiting for ArgoCD Application cleanup." >&2
      echo "The following Applications are still terminating:" >&2
      echo "${pending_applications}" >&2
      echo "01-onprem-platform was not destroyed, so ArgoCD remains available." >&2
      return 1
    fi

    echo "Still waiting for:"
    echo "${pending_applications}"
    sleep "${ARGOCD_CLEANUP_POLL_INTERVAL}"
  done
}

echo "================================="
echo " On-prem Terraform destroy start"
echo "================================="

destroy_layer "02-onprem-workloads"
wait_for_argocd_cleanup
destroy_layer "01-onprem-platform"

echo
echo "================================="
echo " On-prem Terraform destroy complete"
echo "================================="
