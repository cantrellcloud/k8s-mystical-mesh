#!/usr/bin/env bash
#clear
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export NAMESPACE="istio-system"
export OPTIONS="/home/adminlocal/k8s-mystical-mesh/build/sites/${SITE}/${CLUSTER}-cluster"
export PACKAGE="/home/adminlocal/k8s-mystical-mesh/helm/packages"

export CACERTS_DIR="/home/adminlocal/k8s-mystical-mesh/build/misc/istio-cacerts"
export CACERTS_FILE="istio-${SITE}${CLUSTER}-cacerts.yaml"

export ISTIO_BASE_PACKAGE="base-1.27.1.tgz"
export ISTIO_BASE_VALUES="istio-base-values-v1.yaml"

export ISTIO_ISTIOD_PACKAGE="istiod-1.27.1.tgz"
export ISTIO_ISTIOD_VALUES="istio-istiod-values-v1.yaml"

export ISTIO_GATEWAY_PACKAGE="gateway-1.27.1.tgz"
export ISTIO_GATEWAY_VALUES="istio-eastwest-gateway-values-v1.yaml"
export ISTIO_GATEWAY_RESOURCES="istio-gateway-resources-v2.yaml"

export KIALI_OPERATOR_PACKAGE="kiali-operator-2.13.0.tgz"
export KIALI_OPERATOR_VALUES="istio-kiali-operator-values-v1.yaml"

export KIALI_SERVER_PACKAGE="kiali-server-2.13.0.tgz"
export KIALI_SERVER_VALUES="istio-kiali-server-values-v1.yaml"
export KIALI_SERVER_RESOURCES="istio-kiali-server-resources-v1.yaml"
echo
echo ---
echo
kubectl config use-context ${SITE}${CLUSTER}
echo Create and label namespace ${NAMESPACE} on ${SITE}${CLUSTER}-cluster...
echo
kubectl get ns ${NAMESPACE} >/dev/null 2>&1 || kubectl create namespace ${NAMESPACE}
kubectl label --overwrite namespace ${NAMESPACE} topology.istio.io/network=${SITE}${CLUSTER}-net1 --context ${SITE}${CLUSTER}
kubectl label --overwrite namespace ${NAMESPACE} kubernetes.io/metadata.name=${NAMESPACE}
#kubectl label --overwrite namespace ${NAMESPACE} pod-security.kubernetes.io/enforce=privileged --context ${SITE}${CLUSTER}
#kubectl label --overwrite namespace ${NAMESPACE} pod-security.kubernetes.io/audit=privileged --context ${SITE}${CLUSTER}
#kubectl label --overwrite namespace ${NAMESPACE} pod-security.kubernetes.io/warn=privileged --context ${SITE}${CLUSTER}
echo
echo ---
echo
echo Creating Istio CACerts...
kubectl apply -f ${CACERTS_DIR}/${CACERTS_FILE} --namespace ${NAMESPACE} --context ${SITE}${CLUSTER}
echo
echo ---
echo
echo Installing...
kubectl config use-context ${SITE}${CLUSTER}
helm upgrade \
  --install istio-base ${PACKAGE}/${ISTIO_BASE_PACKAGE} \
  --namespace ${NAMESPACE} \
  --values=${OPTIONS}/values/${ISTIO_BASE_VALUES}
echo
echo ---
echo
echo Installing...
kubectl config use-context ${SITE}${CLUSTER}
helm upgrade \
  --install istiod ${PACKAGE}/${ISTIO_ISTIOD_PACKAGE} \
  --namespace ${NAMESPACE} \
  --values=${OPTIONS}/values/${ISTIO_ISTIOD_VALUES}
echo
echo ---
echo
echo Waiting to be ready...
echo
kubectl wait --for=condition=available --timeout=600s deployment/istiod-stable --namespace ${NAMESPACE} --context ${SITE}${CLUSTER}
echo
echo ---
echo
echo Installing...
kubectl config use-context ${SITE}${CLUSTER}
helm upgrade \
  --install istio-eastwestgateway ${PACKAGE}/${ISTIO_GATEWAY_PACKAGE} \
  --namespace ${NAMESPACE} \
  --values=${OPTIONS}/values/${ISTIO_GATEWAY_VALUES}
echo
echo ---
echo
echo Creating Resources...
kubectl apply -f ${OPTIONS}/resources/${ISTIO_GATEWAY_RESOURCES} --namespace ${NAMESPACE} --context ${SITE}${CLUSTER}
echo
echo ---
echo
echo Waiting to be ready...
echo
kubectl wait --for=condition=available --timeout=600s deployment/istio-eastwestgateway-${SITE}${CLUSTER} --namespace ${NAMESPACE} --context ${SITE}${CLUSTER}
echo
echo ---
echo
echo Installing Kiali Operator...
kubectl config use-context ${SITE}${CLUSTER}
helm upgrade \
  --install kiali-operator ${PACKAGE}/${KIALI_OPERATOR_PACKAGE} \
  --namespace ${NAMESPACE} \
  --values=${OPTIONS}/values/${KIALI_OPERATOR_VALUES}
echo
echo ---
echo
echo Waiting to be ready...
echo
kubectl wait --for=condition=available --timeout=600s deployment/kiali-operator --namespace ${NAMESPACE} --context ${SITE}${CLUSTER}
echo
echo ---
echo
echo Installing Kiali Dashboard...
kubectl config use-context ${SITE}${CLUSTER}
helm upgrade \
  --install kiali ${PACKAGE}/${KIALI_SERVER_PACKAGE} \
  --namespace ${NAMESPACE} \
  --values=${OPTIONS}/values/${KIALI_SERVER_VALUES}
echo
echo ---
echo
echo Waiting to be ready...
echo
kubectl wait --for=condition=available --timeout=600s deployment/kiali --namespace ${NAMESPACE} --context ${SITE}${CLUSTER}
echo
echo ---
echo
echo Creating Resources...
kubectl apply -f ${OPTIONS}/resources/${KIALI_SERVER_RESOURCES} --context ${SITE}${CLUSTER}
echo
echo ---
echo
echo Istio Sevice Mesh installed.
echo
