#!/usr/bin/env bash
#clear
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export NAMESPACE="mongo-express"
export OPTIONS="/home/adminlocal/k8s-mystical-mesh/build/sites/${SITE}/${CLUSTER}-cluster"
export PACKAGE="/home/adminlocal/k8s-mystical-mesh/helm/packages"
export CHART="mongo-express-6.5.2.tgz"
export VALUES="mongo-express-${CLUSTER}-cluster-values-v1.yaml"
export RESOURCES=""
echo
echo ---
echo
kubectl config use-context ${SITE}${CLUSTER}
echo Create and label namespace ${NAMESPACE}...
echo
kubectl create namespace ${NAMESPACE}
kubectl label --overwrite namespace ${NAMESPACE} kubernetes.io/metadata.name=${NAMESPACE}
#kubectl label --overwrite namespace ${NAMESPACE} pod-security.kubernetes.io/enforce=privileged
#kubectl label --overwrite namespace ${NAMESPACE} pod-security.kubernetes.io/audit=privileged
#kubectl label --overwrite namespace ${NAMESPACE} pod-security.kubernetes.io/warn=privileged
echo
echo ---
echo
echo Installing MongoDB Express...
helm upgrade \
  --install mongo-express ${PACKAGE}/${CHART} \
  --namespace ${NAMESPACE} \
  --values=${OPTIONS}/values/${VALUES}
echo
echo ---
echo
echo MongoDB Express installed.
echo