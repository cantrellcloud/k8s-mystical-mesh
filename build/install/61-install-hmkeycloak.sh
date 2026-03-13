#!/usr/bin/env bash
#clear
set -euo pipefail
if [ $# -lt 1 ]; then
  echo "Usage: $0 <kube-context>" >&2
  exit 2
fi
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export K8_CONTEXT=${1}${2}
export NAMESPACE="keycloak"
export OPTIONS="/home/adminlocal/k8s-mystical-mesh/build/sites/all"
export MISC_FILES="/home/adminlocal/k8s-mystical-mesh/build/misc"
export RELEASE="hmkeycloak"
export RESOURCES="hmkeycloak-resources-v3.yaml"
export CA_ROOT_SECRET="hypermute-ca-bundle-secret-v1.yaml"
export KEYCLOAK_CR="keycloak-cr-hypermute-v3.yaml"
export KEYTAB_FILE="hmkeycloak.keytab"
echo -e "# --- Switching to context ${K8_CONTEXT}..."
kubectl config use-context "${K8_CONTEXT}"
echo -e "# --- Ensuring namespace exists (${NAMESPACE})..."
kubectl create namespace "${NAMESPACE}" >/dev/null 2>&1 || true
echo
echo ---
echo
echo -e "# --- Create CA secret..."
echo
kubectl apply -f ${OPTIONS}/resources/${CA_ROOT_SECRET}
echo
echo ---
echo
echo -e "# --- Create keytab secret..."
echo
kubectl -n "${NAMESPACE}" create secret generic hmkeycloak-keytab \
  --from-file=hmkeycloak.keytab="${MISC_FILES}/keycloak/${KEYTAB_FILE}" \
  --dry-run=client -o yaml | kubectl apply -f -
echo
echo ---
echo
echo -e "# --- Applying resources (cert/ingress/etc)..."
kubectl apply -f ${OPTIONS}/resources/${RESOURCES}
echo
echo ---
echo
echo -e "# --- Installing ${RELEASE}..."
kubectl apply -f ${OPTIONS}/resources/${RESOURCES}
kubectl apply -f ${OPTIONS}/resources/${KEYCLOAK_CR}
echo
echo ---
echo
echo Waiting for ${RELEASE} to be ready...
sleep 3s
kubectl wait --for=condition=available --timeout=600s pod ${RELEASE}-0 --namespace ${NAMESPACE}
echo
echo ---
echo
echo ${RELEASE} installed.
echo
