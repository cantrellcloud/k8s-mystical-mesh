#!/usr/bin/env bash
#clear
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export NAMESPACE="contour"
export OPTIONS="/home/adminlocal/k8s-mystical-mesh/build/sites/${SITE}/${CLUSTER}-cluster"
export PACKAGE="/home/adminlocal/k8s-mystical-mesh/helm/packages"
export RELEASE="contour"
export CHART="contour-21.1.4.tgz"
export VALUES="contour-values-v4.yaml"
export RESOURCES="contour-resources-${CLUSTER}-cluster-v1.yaml"
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
echo Installing Contour Ingress...
helm upgrade \
  --install ${RELEASE} ${PACKAGE}/${CHART} \
  --namespace ${NAMESPACE} \
  --values=${OPTIONS}/values/${VALUES}
echo
echo ---
echo
echo Waiting for Contour Ingress to be ready...
echo
kubectl wait --for=condition=available --timeout=600s deployment/${RELEASE}-contour --namespace ${NAMESPACE}
#echo Sleeping for 5 minutes
#sleep 5m
echo
echo ---
echo
echo Creating Contour Ingress Resources...
kubectl apply -f ${OPTIONS}/resources/${RESOURCES}
echo
echo ---
echo
echo Contour Ingress installed.
echo
