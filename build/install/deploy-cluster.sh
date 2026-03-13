#!/usr/bin/env bash
clear
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export DEPLOY_DIR=/home/adminlocal/k8s-mystical-mesh/build/install
echo
echo "Deploying ${SITE}${CLUSTER}'s cluster default applications..."
echo
echo Deploying coredns patch...
source ${DEPLOY_DIR}/00-patch-coredns-v1.sh ${SITE} ${CLUSTER}
echo
echo ---
echo
echo Deploying cert-manager...
source ${DEPLOY_DIR}/01-install-cert-manager.sh ${SITE} ${CLUSTER}
echo
echo ---
echo
echo Deploying metallb...
source ${DEPLOY_DIR}/02-install-metallb.sh ${SITE} ${CLUSTER}
echo
echo ---
echo
echo Deploying contour...
source ${DEPLOY_DIR}/03-install-contour-ingress.sh ${SITE} ${CLUSTER}
echo
echo ---
echo
echo Deploying trident...
source ${DEPLOY_DIR}/30-install-trident-operator.sh ${SITE} ${CLUSTER}
source ${DEPLOY_DIR}/31-configure-trident-operator.sh ${SITE} ${CLUSTER}
echo
echo ---
echo
echo Deployment completed...

