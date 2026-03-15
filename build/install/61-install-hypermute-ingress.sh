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
export NAMESPACE="hypermute-ingress"
export OPTIONS="/home/adminlocal/k8s-mystical-mesh/build/sites/${SITE}/${CLUSTER}-cluster"
export PACKAGE="/home/adminlocal/k8s-mystical-mesh/helm/packages"
export RELEASE="hypermute"
export CHART="contour-21.1.4.tgz"
export VALUES="hmingress-values-v4.yaml"
export RESOURCES="hmingress-resources-${CLUSTER}-cluster-v1.yaml"

echo
echo ---
echo
kubectl config use-context "${SITE}${CLUSTER}"

echo "Create and label namespace ${NAMESPACE}..."
echo
kubectl create namespace "${NAMESPACE}" >/dev/null 2>&1 || true
kubectl label --overwrite namespace "${NAMESPACE}" kubernetes.io/metadata.name="${NAMESPACE}"

echo
echo ---
echo
echo "Installing Contour Ingress..."
helm upgrade       --install "${RELEASE}" "${PACKAGE}/${CHART}"       --namespace "${NAMESPACE}"       --values="${OPTIONS}/values/${VALUES}"

echo
echo ---
echo
echo "Waiting for Contour Ingress to be ready..."
echo
kubectl wait --for=condition=available --timeout=600s deployment/"${RELEASE}"-contour --namespace "${NAMESPACE}"

echo
echo ---
echo
echo "Creating site-specific Contour resources..."
kubectl apply -f "${OPTIONS}/resources/${RESOURCES}"

echo
echo ---
echo
echo "Contour Ingress installed."
echo
