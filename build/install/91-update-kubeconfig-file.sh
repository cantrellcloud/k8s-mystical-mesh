#!/usr/bin/env bash
#clear
echo
echo Exporting variables...
export KUBE_CONFIG_SRCDIR="/home/adminlocal/.kube"
export KUBE_CONFIG_DSTDIR="/home/adminlocal/k8s-mystical-mesh/build/misc"
echo
echo ---
echo
echo Copy .kube/config to misc/kubeconfig.yaml
cp ${KUBE_CONFIG_SRCDIR}/config ${KUBE_CONFIG_DSTDIR}/kubeconfig.yaml
echo
ls ${KUBE_CONFIG_DSTDIR}
echo
