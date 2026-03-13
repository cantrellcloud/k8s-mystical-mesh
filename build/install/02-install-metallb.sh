#!/usr/bin/env bash
#clear
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export NAMESPACE="metallb-system"
export OPTIONS="/home/adminlocal/k8s-mystical-mesh/build/sites"
export PACKAGE="/home/adminlocal/k8s-mystical-mesh/helm/packages"
export RELEASE="metallb"
#export CHART="metallb-6.4.22.tgz"
#export VALUES="bitnami-metallb-values-v6422-v1.yaml"
export CHART="metallb-0.15.2.tgz"
export VALUES="metallb-metallb-values-v0152-v1.yaml"
export RESOURCES="metallb-ippool-layer2-advertise-${SITE}${CLUSTER}-cluster-v1.yaml"
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
echo Installing MetalLB...
helm upgrade --install ${RELEASE} ${PACKAGE}/${CHART} \
  --namespace ${NAMESPACE} \
  --values=${OPTIONS}/all/values/${VALUES}
echo
echo
echo ---
echo
echo Waiting for MetalLB to be ready...
kubectl wait --for=condition=available --timeout=600s deployment/metallb-controller --namespace ${NAMESPACE}
sleep 10s
echo
echo ---
echo
echo Creating MetalLB Layer2 Advertisment...
kubectl create -f ${OPTIONS}/${SITE}/${CLUSTER}-cluster/resources/${RESOURCES}
echo
echo ---
echo
echo MetalLB installed.
echo
