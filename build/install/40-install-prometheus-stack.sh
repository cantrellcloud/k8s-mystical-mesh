#!/usr/bin/env bash
#clear
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export NAMESPACE="monitoring"
export OPTIONS="/home/adminlocal/k8s-mystical-mesh/build/sites"
export PACKAGE="/home/adminlocal/k8s-mystical-mesh/helm/packages"
export MONITORING="/home/adminlocal/k8s-mystical-mesh/monitoring"
export RELEASE="prometheus"
export CHART="kube-prometheus-stack-80.2.0.tgz"
export VALUES="kube-prometheus-stack-values-${SITE}${CLUSTER}-v9.yaml"
export RESOURCES="kube-prometheus-stack-resources-${SITE}${CLUSTER}-v9.yaml"
export CABUNDLE="preprod-ca-bundle-secret-v1.yaml"
export GRAFANA_CREDS="grafana-admin-credentials-j64manager-v1.yaml"
echo
echo ---
echo
kubectl config use-context ${SITE}${CLUSTER}
echo Create and label namespace...
echo
kubectl get ns ${NAMESPACE} >/dev/null 2>&1 || kubectl create namespace ${NAMESPACE}
#kubectl label --overwrite namespace ${NAMESPACE} istio.io/rev=stable
kubectl label --overwrite namespace ${NAMESPACE} kubernetes.io/metadata.name=${NAMESPACE}
#kubectl label --overwrite namespace ${NAMESPACE} pod-security.kubernetes.io/enforce=privileged
#kubectl label --overwrite namespace ${NAMESPACE} pod-security.kubernetes.io/audit=privileged
#kubectl label --overwrite namespace ${NAMESPACE} pod-security.kubernetes.io/warn=privileged
echo
echo ---
echo
echo Creating RootCA Secret...
kubectl apply -f ${OPTIONS}/all/resources/${CABUNDLE} -n ${NAMESPACE}
echo
echo ---
echo
echo Creating Grafana Admin Credentials...
kubectl apply -f ${OPTIONS}/${SITE}/${CLUSTER}-cluster/resources/${GRAFANA_CREDS} -n ${NAMESPACE}
echo
echo ---
echo
echo Installing Prometheus Stack...
echo
helm upgrade \
  --install ${RELEASE} ${PACKAGE}/${CHART} \
  --namespace ${NAMESPACE} \
  -f=${OPTIONS}/${SITE}/${CLUSTER}-cluster/values/${VALUES}
echo
echo ---
echo
echo Waiting for Prometheus Stack to be ready...
kubectl rollout status deployment.apps/prometheus-kube-state-metrics -n ${NAMESPACE} --timeout=600s
kubectl rollout status deployment/${SITE}${CLUSTER} -n ${NAMESPACE} --timeout=600s
kubectl rollout status deployment/prometheus-grafana -n ${NAMESPACE} --timeout=600s
echo
echo ---
echo
echo Creating Prometheus Resources...
kubectl apply -f ${OPTIONS}/${SITE}/${CLUSTER}-cluster/resources/${RESOURCES}
echo
echo ---
echo
echo Prometheus Stack installed.
echo
