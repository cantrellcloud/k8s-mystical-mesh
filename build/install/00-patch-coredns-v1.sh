#!/usr/bin/env bash
#clear
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export NAMESPACE="kube-system"
export OPTIONS="/home/adminlocal/k8s-mystical-mesh/build/sites/all"
export RESOURCES1="coredns-configmap-rke2-patch-v1.yaml"
echo
echo ---
echo
kubectl config use-context ${SITE}${CLUSTER}
echo
echo Creating ${RELEASE} resources
kubectl apply -f ${OPTIONS}/resources/${RESOURCES1} --namespace kube-system
echo
echo ---
echo
echo CoreDNS patched.
echo
