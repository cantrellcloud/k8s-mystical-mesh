#!/usr/bin/env bash
#clear
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export NAMESPACE="istio-system"
export CLUSTERS="j64manager j64domain j52domain r01domain"
echo
kubectl config use-context ${SITE}${CLUSTER}
echo Create and label namespace ${NAMESPACE} on each cluster...
echo
for c in ${CLUSTERS}; do
  echo "## $c"
  kubectl get ns ${NAMESPACE} --context $c >/dev/null 2>&1 || kubectl create namespace ${NAMESPACE} --context $c
  kubectl label --overwrite namespace ${NAMESPACE} topology.istio.io/network=$c-net1 --context $c
  kubectl label --overwrite namespace ${NAMESPACE} kubernetes.io/metadata.name=${NAMESPACE}
  #kubectl label --overwrite namespace ${NAMESPACE} pod-security.kubernetes.io/enforce=privileged --context $c
  #kubectl label --overwrite namespace ${NAMESPACE} pod-security.kubernetes.io/audit=privileged --context $c
  #kubectl label --overwrite namespace ${NAMESPACE} pod-security.kubernetes.io/warn=privileged --context $c
  echo
  echo ---
  echo
done

echo
echo ---
echo
echo Creating Resources...
istioctl create-remote-secret --context j64manager --name=j64manager | kubectl apply -f - --context j64domain
istioctl create-remote-secret --context j64manager --name=j64manager | kubectl apply -f - --context j52domain
istioctl create-remote-secret --context j64manager --name=j64manager | kubectl apply -f - --context r01domain

istioctl create-remote-secret --context j64domain --name=j64domain | kubectl apply -f - --context j64manager
istioctl create-remote-secret --context j64domain --name=j64domain | kubectl apply -f - --context j52domain
istioctl create-remote-secret --context j64domain --name=j64domain | kubectl apply -f - --context r01domain

istioctl create-remote-secret --context j52domain --name=j52domain | kubectl apply -f - --context j64manager
istioctl create-remote-secret --context j52domain --name=j52domain | kubectl apply -f - --context j64domain
istioctl create-remote-secret --context j52domain --name=j52domain | kubectl apply -f - --context r01domain

istioctl create-remote-secret --context r01domain --name=r01domain | kubectl apply -f - --context j64manager
istioctl create-remote-secret --context r01domain --name=r01domain | kubectl apply -f - --context j64domain
istioctl create-remote-secret --context r01domain --name=r01domain | kubectl apply -f - --context j52domain
echo
echo ---
echo
echo Getting secrets...
echo
kubectl get secret --namespace ${NAMESPACE} --context j64manager
echo
kubectl get secret --namespace ${NAMESPACE} --context j64domain
echo
kubectl get secret --namespace ${NAMESPACE} --context j52domain
echo
kubectl get secret --namespace ${NAMESPACE} --context r01domain
echo
echo ---
echo
echo Istio secrets configured.
echo
