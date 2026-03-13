#!/usr/bin/env bash
set -euo pipefail
#clear
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export NAMESPACE="mongodb"
export OPTIONS="/home/adminlocal/k8s-mystical-mesh/build/sites/${SITE}/${CLUSTER}-cluster"
export PACKAGE="/home/adminlocal/k8s-mystical-mesh/helm/packages"
export RELEASE="opsmanager"
export RESOURCES="mongodb-opsmanager-https-v2.yaml"
echo
echo ---
echo
kubectl config use-context ${SITE}${CLUSTER}
echo Creating ${RELEASE} resources...
kubectl apply -f ${OPTIONS}/resources/${RESOURCES} -n ${NAMESPACE}
echo
echo ---
echo
echo Waiting for ${RELEASE} to be ready...
sleep 15
kubectl rollout status --watch --timeout=600s statefulset.apps/${RELEASE}-db --namespace ${NAMESPACE}
sleep 5
kubectl rollout status --watch --timeout=900s statefulset.apps/${RELEASE} --namespace ${NAMESPACE}
echo
echo ---
echo
echo ${RELEASE} installed.
echo