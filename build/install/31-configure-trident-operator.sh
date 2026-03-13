#!/usr/bin/env bash
#clear
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export NAMESPACE="trident-system"
export OPTIONS="/home/adminlocal/k8s-mystical-mesh/build/sites/all"
export RESOURCES="trident-storage-backend-v2.yaml"
export RESOURCES2="trident-storage-storageclasses-v2.yaml"
echo
echo ---
echo
kubectl config use-context ${SITE}${CLUSTER}
echo Creating Netapp Trident backend and storage classes...
kubectl apply -f ${OPTIONS}/resources/${RESOURCES} --namespace ${NAMESPACE}
sleep 3
kubectl apply -f ${OPTIONS}/resources/${RESOURCES2}
echo ---
echo
echo Trident backend and storage classes created.
echo
