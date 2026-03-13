#!/usr/bin/env bash
#clear
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export NAMESPACE="mongodb"
export OPTIONS="/home/adminlocal/k8s-mystical-mesh/build/sites/${SITE}/${CLUSTER}-cluster"
export PACKAGE="/home/adminlocal/k8s-mystical-mesh/helm/packages"
export RELEASE="mongodb-rocketchat-replicaset"
export STATEFULSET_NAME="rocketchat"
export RESOURCES="mongodb-rocketchat-replicaset-https-v2a.yaml"
export FILE01="mongodb-multicluster-serviceaccount-role-binding-v1.yaml"
export PROMETHEUS_TLS_CERT="prometheus-tls"
export PROMETHEUS_NAMESPACE="monitoring"
echo
echo ---
echo
kubectl apply -f ${OPTIONS}/resources/${FILE01} -n ${NAMESPACE} --context j64manager
kubectl apply -f ${OPTIONS}/resources/${FILE01} -n ${NAMESPACE} --context j64domain
kubectl apply -f ${OPTIONS}/resources/${FILE01} -n ${NAMESPACE} --context j52domain
kubectl apply -f ${OPTIONS}/resources/${FILE01} -n ${NAMESPACE} --context r01domain
kubectl config use-context ${SITE}${CLUSTER}
echo Creating ${RELEASE} resources...
kubectl apply -f ${OPTIONS}/resources/${RESOURCES} -n ${NAMESPACE}
echo
echo ---
echo
echo Waiting for ${RELEASE} to be ready...
sleep 15
kubectl rollout status --watch --timeout=600s statefulset.apps/${STATEFULSET_NAME}-db-0 --namespace ${NAMESPACE} --context j64domain
kubectl rollout status --watch --timeout=600s statefulset.apps/${STATEFULSET_NAME}-db-1 --namespace ${NAMESPACE} --context j52domain
kubectl rollout status --watch --timeout=600s statefulset.apps/${STATEFULSET_NAME}-db-2 --namespace ${NAMESPACE} --context r01domain
echo
echo ---
echo
echo ${RELEASE} installed.
echo
