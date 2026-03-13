#!/usr/bin/env bash
#clear
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export NAMESPACE="portainer"
export OPTIONS="/home/adminlocal/k8s-mystical-mesh/build/sites"
export PACKAGE="/home/adminlocal/k8s-mystical-mesh/helm/packages"
export RELEASE="portainer"
export CHART="portainer-2.33.6.tgz"
export VALUES="portainer-values-v1.yaml"
export RESOURCES="portainer-resources-v1.yaml"
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
echo Creating ${RELEASE} resources...
kubectl apply -f ${OPTIONS}/${SITE}/${CLUSTER}-cluster/resources/${RESOURCES}
echo
echo ---
echo
echo Installing ${RELEASE}...
helm upgrade --install ${RELEASE} ${PACKAGE}/${CHART} \
  --namespace ${NAMESPACE} \
  --values=${OPTIONS}/${SITE}/${CLUSTER}-cluster/values/${VALUES}
echo
echo
echo ---
echo
echo Waiting for ${RELEASE} to be ready...
kubectl wait --for=condition=available --timeout=600s deployment/${RELEASE} --namespace ${NAMESPACE}
sleep 10s
echo
echo ---
echo
echo ${RELEASE} installed.
echo
