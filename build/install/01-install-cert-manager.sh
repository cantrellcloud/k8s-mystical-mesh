#!/usr/bin/env bash
#clear
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export NAMESPACE="cert-manager"
export OPTIONS="/home/adminlocal/k8s-mystical-mesh/build/sites/all"
export PACKAGE="/home/adminlocal/k8s-mystical-mesh/helm/packages"
export RELEASE="cert-manager"
export CHART="cert-manager-1.5.14.tgz"
export VALUES="bitnami-cert-manager-values-v1514-v1.yaml"
export RESOURCES="cert-manager-resources-v1.yaml"
export ROOTCA="preprod-ca-secret-v1.yaml"
echo
echo ---
echo
echo Installing Certificate Manager...
kubectl config use-context ${SITE}${CLUSTER}
helm upgrade --install ${RELEASE} ${PACKAGE}/${CHART} \
  --namespace ${NAMESPACE} \
  --create-namespace \
  --values=${OPTIONS}/values/${VALUES}
echo
echo ---
echo
echo Waiting for Certificate Manager to be ready...
kubectl wait --for=condition=available --timeout=600s deployment/${RELEASE}-controller --namespace ${NAMESPACE}
kubectl wait --for=condition=available --timeout=600s deployment/${RELEASE}-cainjector --namespace ${NAMESPACE}
kubectl wait --for=condition=available --timeout=600s deployment/${RELEASE}-webhook --namespace ${NAMESPACE}
echo
echo ---
echo
echo Creating ${RELEASE} resources
kubectl create -f ${OPTIONS}/resources/${ROOTCA} --namespace cert-manager
kubectl create -f ${OPTIONS}/resources/${RESOURCES} --namespace cert-manager
echo
echo ---
echo
echo Certificate Manager installed.
echo
