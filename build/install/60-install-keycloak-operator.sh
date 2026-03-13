#!/usr/bin/env bash
set -euo pipefail
if [ $# -lt 1 ]; then
  echo "Usage: $0 <kube-context>" >&2
  exit 2
fi
#clear
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export NAMESPACE="keycloak"
export OPTIONS="/home/adminlocal/k8s-mystical-mesh/build/sites/all"
export PACKAGE="/home/adminlocal/k8s-mystical-mesh/helm/packages"
export RELEASE="keycloak-operator"
export CA_ROOT_SECRET="preprod-ca-bundle-secret-v1.yaml"
export CRDS="keycloak-crds-v1.yaml"
export REALMIMPORT="keycloak-realmimports-v1.yaml"
export OPERATOR="keycloak-operator-v1.yaml"
echo
echo ---
echo
kubectl config use-context ${SITE}${CLUSTER}
echo Create and label namespace ${NAMESPACE}...
echo
kubectl get ns ${NAMESPACE} >/dev/null 2>&1 || kubectl create namespace ${NAMESPACE}
kubectl label --overwrite namespace ${NAMESPACE} istio.io/rev=stable
kubectl label --overwrite namespace ${NAMESPACE} kubernetes.io/metadata.name=${NAMESPACE}
#kubectl label --overwrite namespace ${NAMESPACE} pod-security.kubernetes.io/enforce=privileged
#kubectl label --overwrite namespace ${NAMESPACE} pod-security.kubernetes.io/audit=privileged
#kubectl label --overwrite namespace ${NAMESPACE} pod-security.kubernetes.io/warn=privileged
echo
echo ---
echo
echo Install crds...
echo
kubectl apply -f ${OPTIONS}/resources/${CRDS}
echo
echo ---
echo
echo Install realmimports...
echo
kubectl apply -f ${OPTIONS}/resources/${REALMIMPORT}
echo
echo ---
echo
echo Install the operator...
echo
kubectl apply -f ${OPTIONS}/resources/${OPERATOR} -n ${NAMESPACE}
echo
echo ---
echo
echo ${RELEASE} installed.
echo