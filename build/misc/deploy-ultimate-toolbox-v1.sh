#!/usr/bin/env bash
set -euo pipefail
clear
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export NAMESPACE="portainer"
export OPTIONS="/home/adminlocal/k8s-mystical-mesh/build/sites/all"
export PACKAGE="/home/adminlocal/k8s-mystical-mesh/helm/packages"
export RELEASE="toolbox"
export CHART="ultimate-k8s-toolbox-chart-1.0.1.tgz"
export VALUES="ultimate-toolbox-values-v1.yaml"
export RESOURCES="ultimate-toolbox-ca-resources-v1.yaml"
echo
echo ---
echo
kubectl config use-context ${SITE}${CLUSTER}
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
kubectl rollout status --watch --timeout=600s deploy/toolbox-ultimate-k8s-toolbox --namespace ${NAMESPACE}
echo
echo ---
echo
echo ${RELEASE} installed.
echo