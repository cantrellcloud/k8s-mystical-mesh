#!/usr/bin/env bash
#clear
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export NAMESPACE="trident-system"
export OPTIONS="/home/adminlocal/k8s-mystical-mesh/build/sites/all"
export PACKAGE="/home/adminlocal/k8s-mystical-mesh/helm/packages"
export CHART="trident-operator-100.2510.0.tgz"
export VALUES="trident-values-v2.yaml"
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
echo Installing Trident...
helm upgrade --install trident-operator ${PACKAGE}/${CHART} \
  --namespace ${NAMESPACE} \
  --values=${OPTIONS}/values/${VALUES}
echo
echo ---
echo
echo Trident installed.
echo
