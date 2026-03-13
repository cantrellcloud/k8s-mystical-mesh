#!/usr/bin/env bash
#clear
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export NAMESPACE="monitoring"
export MONITORING="/home/adminlocal/k8s-mystical-mesh/build/monitoring"
echo
echo ---
echo
kubectl config use-context ${SITE}${CLUSTER}
echo
echo ---
echo
echo Creating Grafana Dashboards and Rules...
cd ${MONITORING}/dashboards
kubectl apply -n ${NAMESPACE} -f .
echo
cd ${MONITORING}/rules
kubectl apply -n ${NAMESPACE} -f .
echo
cd /home/adminlocal/k8s-mystical-mesh/build/install
echo
echo ---
echo
echo Grafana Dashboard and Rules created.
echo
