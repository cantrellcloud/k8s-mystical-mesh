#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <site> <cluster>" >&2
  echo "Example: $0 j64 domain" >&2
  exit 2
fi

echo
echo Exporting variables...
export SITE="${1}"
export CLUSTER="${2}"
export K8_CONTEXT="${SITE}${CLUSTER}"
export NAMESPACE="keycloak"
export OPTIONS="/home/adminlocal/k8s-mystical-mesh/build/sites/all"
export MISC_FILES="/home/adminlocal/k8s-mystical-mesh/build/misc"
export RELEASE="hmingress"
export INGRESS="hypermute-contour-ingress-v1.yaml"

echo -e "# --- Switching to context ${K8_CONTEXT}..."
kubectl config use-context "${K8_CONTEXT}"

echo -e "# --- Ensuring namespace exists (${NAMESPACE})..."
kubectl create namespace "${NAMESPACE}" >/dev/null 2>&1 || true

echo
echo ---
echo
echo "Creating hypermute ingress controller..."
kubectl apply -f "${OPTIONS}/resources/${INGRESS}"

echo
echo ---
echo
echo "${RELEASE} installed."
echo
