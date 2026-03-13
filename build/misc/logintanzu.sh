#!/usr/bin/env bash
# Augument validation check
if [ "$#" -ne 1 ]; then
        echo "Usage: $0 <vsphere-username>"
        exit 1
fi
echo
echo Exporting variables...
export TANZU_USER=${1}
export TANZU_SERVER="vcsa102supapi.dev.kube"
echo ---
echo j64manager
kubectl vsphere login --server=${TANZU_SERVER} --vsphere-username ${TANZU_USER} --tanzu-kubernetes-cluster-name j64manager --tanzu-kubernetes-cluster-namespace j64
echo ---
echo j64domain
kubectl vsphere login --server=${TANZU_SERVER} --vsphere-username ${TANZU_USER} --tanzu-kubernetes-cluster-name j64domain --tanzu-kubernetes-cluster-namespace j64
echo ---
echo j52domain
kubectl vsphere login --server=${TANZU_SERVER} --vsphere-username ${TANZU_USER} --tanzu-kubernetes-cluster-name j52domain --tanzu-kubernetes-cluster-namespace j52
echo ---
echo r01domain
kubectl vsphere login --server=${TANZU_SERVER} --vsphere-username ${TANZU_USER} --tanzu-kubernetes-cluster-name r01domain --tanzu-kubernetes-cluster-namespace r01
