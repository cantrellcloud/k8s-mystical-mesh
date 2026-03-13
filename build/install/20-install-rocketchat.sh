#!/usr/bin/env bash
#clear
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export NAMESPACE="rocketchat"
export OPTIONS="/home/adminlocal/k8s-mystical-mesh/build/sites/all"
export PACKAGE="/home/adminlocal/k8s-mystical-mesh/helm/packages"
export RELEASE="rocketchat"
export CHART="rocketchat-6.27.1.tgz"
export VALUES="rocketchat-microservices-values-v2.yaml"
export RESOURCES="rocketchat-resources-v5.yaml"
echo
echo ---
echo
echo Switch to correct context...
kubectl config use-context ${SITE}${CLUSTER}
echo
echo ---
echo
echo Create and label namespace...
echo
kubectl create namespace ${NAMESPACE}
kubectl get ns ${NAMESPACE} >/dev/null 2>&1 || kubectl create namespace ${NAMESPACE}
kubectl label --overwrite namespace ${NAMESPACE} istio.io/rev=stable
kubectl label --overwrite namespace ${NAMESPACE} kubernetes.io/metadata.name=${NAMESPACE}
#kubectl label --overwrite namespace ${NAMESPACE} pod-security.kubernetes.io/enforce=privileged
#kubectl label --overwrite namespace ${NAMESPACE} pod-security.kubernetes.io/audit=privileged
#kubectl label --overwrite namespace ${NAMESPACE} pod-security.kubernetes.io/warn=privileged
echo
echo ---
echo
echo Creating Rocket.Chat resources...
echo
kubectl apply -f ${OPTIONS}/resources/${RESOURCES}
echo
echo ---
echo
echo Installing Rocket.Chat...
helm upgrade \
  --install ${RELEASE} ${PACKAGE}/${CHART} \
  --namespace ${NAMESPACE} \
  --values=${OPTIONS}/values/${VALUES}
echo
echo ---
echo
echo Rocket.Chat installed.
echo
