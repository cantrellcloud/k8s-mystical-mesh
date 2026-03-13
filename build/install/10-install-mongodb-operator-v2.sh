#!/usr/bin/env bash
set -euo pipefail
#clear
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export NAMESPACE="mongodb-operator"
export OPTIONS="/home/adminlocal/k8s-mystical-mesh/build/sites/${SITE}/${CLUSTER}-cluster"
export PACKAGE="/home/adminlocal/k8s-mystical-mesh/helm/packages"
export RELEASE="mongodb-operator"
export CHART="mongodb-kubernetes-1.5.0.tgz"
export VALUES="mongodb-operator-values-v4.yaml"
export RESOURCES="mongodb-operator-resources-v1.yaml"
export CRDS="mongodb-operator-crds-v2.yaml"
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
echo Creating ${RELEASE} resources...
kubectl apply -f ${OPTIONS}/resources/${RESOURCES}
echo ---
echo
echo Installing ${RELEASE}...
helm upgrade \
  --install ${RELEASE} ${PACKAGE}/${CHART} \
  --namespace ${NAMESPACE} \
  --values=${OPTIONS}/values/${VALUES}
echo
echo ---
echo
echo Waiting for ${RELEASE} to be ready...
kubectl rollout status --watch --timeout=600s deployment/mongodb-kubernetes-operator --namespace ${NAMESPACE}
echo
echo ---
echo
echo ${RELEASE} installed.
echo