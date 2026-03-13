#!/usr/bin/env bash
#clear
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export NAMESPACE="nats-system"
export OPTIONS="/home/adminlocal/k8s-mystical-mesh/build/sites/all"
export PACKAGE="/home/adminlocal/k8s-mystical-mesh/helm/packages"
export RELEASE="nats"
export CHART="nats-2.12.2.tgz"
export VALUES="nats-cluster-values-v3.yaml"
echo
echo ---
echo
echo Installing NATS Cluster...
kubectl config use-context ${SITE}${CLUSTER}
echo
kubectl --context ${SITE}${CLUSTER} get ns ${NAMESPACE} >/dev/null 2>&1 || kubectl create namespace ${NAMESPACE} --context ${SITE}${CLUSTER}
echo
kubectl --context ${SITE}${CLUSTER} label --overwrite namespace ${NAMESPACE} istio.io/rev=stable
kubectl label --overwrite namespace ${NAMESPACE} kubernetes.io/metadata.name=${NAMESPACE}
#kubectl --context ${SITE}${CLUSTER} label --overwrite namespace ${NAMESPACE} pod-security.kubernetes.io/enforce=privileged
#kubectl --context ${SITE}${CLUSTER} label --overwrite namespace ${NAMESPACE} pod-security.kubernetes.io/audit=privileged
#kubectl --context ${SITE}${CLUSTER} label --overwrite namespace ${NAMESPACE} pod-security.kubernetes.io/warn=privileged
helm upgrade --install ${RELEASE} ${PACKAGE}/${CHART} \
  --namespace ${NAMESPACE} \
  --values=${OPTIONS}/values/${VALUES}
echo
echo ---
echo
echo Waiting for NATS Cluster to be ready...
kubectl wait --for=condition=available --timeout=600s deployment/nats-box --namespace ${NAMESPACE} --context ${SITE}${CLUSTER}
kubectl rollout status --watch --timeout=600s statefulset.apps/${RELEASE} --namespace ${NAMESPACE} --context ${SITE}${CLUSTER}
echo
echo ---
echo
echo NATS installed.
echo
