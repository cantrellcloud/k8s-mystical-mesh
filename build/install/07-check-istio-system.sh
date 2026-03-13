#!/usr/bin/env bash
#clear
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export NAMESPACE="istio-system"
export OPTIONS="/home/adminlocal/k8s-mystical-mesh/build/sites/${SITE}/${CLUSTER}-cluster"
export RESOURCES="check-istio-multicluster-config-v2.sh"
echo
echo ---
echo
echo Creating Resources...
kubectl config use-context ${SITE}${CLUSTER}
source ${OPTIONS}/resources/${RESOURCES}
echo
echo ---
echo
echo Istio configured.
echo
