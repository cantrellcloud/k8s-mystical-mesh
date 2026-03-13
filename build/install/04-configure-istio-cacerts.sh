#!/usr/bin/env bash
#clear
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export NAMESPACE="istio-system-cacerts"
export CLUSTERS="j64manager j64domain j52domain r01domain"
export MAKEDIR="/home/adminlocal/k8s-mystical-mesh/apps/istio/istio-1.27.1"
export CACERTS_DIR="/home/adminlocal/k8s-mystical-mesh/build/misc/istio-cacerts"
echo
kubectl config use-context ${SITE}${CLUSTER}
echo
echo Generate Istio CACerts
echo
kubectl --context j64manager get ns ${NAMESPACE} >/dev/null 2>&1 || kubectl --context j64manager create namespace ${NAMESPACE}

mkdir -p ${MAKEDIR}/certs
cd ${MAKEDIR}/certs
make -f ../tools/certs/Makefile.selfsigned.mk root-ca

for c in ${CLUSTERS}; do
  echo "## $c"
  make -f ../tools/certs/Makefile.selfsigned.mk $c-cacerts
  echo
  echo ---
  echo
done

mkdir -p ${CACERTS_DIR}

for c in ${CLUSTERS}; do
  echo "## $c"
  kubectl create secret generic $c-cacerts --from-file=$c/ca-cert.pem --from-file=$c/ca-key.pem --from-file=$c/root-cert.pem --from-file=$c/cert-chain.pem --namespace ${NAMESPACE}
  echo
  echo "getting istio-cacert secret"
  kubectl get secret $c-cacerts --namespace ${NAMESPACE} -o yaml > ${CACERTS_DIR}/istio-$c-cacerts.yaml
  sed -i '/creationTimestamp:/d' ${CACERTS_DIR}/istio-$c-cacerts.yaml
  sed -i '/resourceVersion:/d' ${CACERTS_DIR}/istio-$c-cacerts.yaml
  sed -i '/uid:/d' ${CACERTS_DIR}/istio-$c-cacerts.yaml
  sed -i "s/$c-//" ${CACERTS_DIR}/istio-$c-cacerts.yaml
  sed -i 's/istio-system-cacerts/istio-system/' ${CACERTS_DIR}/istio-$c-cacerts.yaml
  echo
  echo ---
  echo
done
echo
echo ---
echo
echo Getting secrets...
echo
kubectl get secret --namespace ${NAMESPACE} --context j64manager
echo
echo Deleting ${NAMESPACE} namespace
kubectl delete namespace ${NAMESPACE}
echo
echo ---
echo
echo Istio certificates configured.
echo
