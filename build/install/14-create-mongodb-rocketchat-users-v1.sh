#!/usr/bin/env bash
#clear
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export NAMESPACE="mongodb"
export OPTIONS="/home/adminlocal/k8s-mystical-mesh/build/sites/${SITE}/${CLUSTER}-cluster"
export PACKAGE="/home/adminlocal/k8s-mystical-mesh/helm/packages"
export RELEASE="mongodb-users"
export RESOURCES0="mongodb-rocketchat-users-rktadmin-v1.yaml"
export RESOURCES1="mongodb-rocketchat-users-rktservice-v1.yaml"
echo
echo ---
echo
kubectl config use-context ${SITE}${CLUSTER}
echo Creating ${RELEASE} resources...
kubectl apply -f ${OPTIONS}/resources/${RESOURCES0} -n ${NAMESPACE}
kubectl apply -f ${OPTIONS}/resources/${RESOURCES1} -n ${NAMESPACE}
echo
echo ---
echo
echo ${RELEASE} installed.
echo
