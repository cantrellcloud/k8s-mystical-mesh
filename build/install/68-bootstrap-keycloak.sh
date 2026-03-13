#!/usr/bin/env bash
clear
echo
echo Exporting variables...
export      K8_CONTEXT=${1}
export     SITE_PREFIX=$(echo ${K8_CONTEXT} | grep -o '^[^-]*')
export       NAMESPACE=keycloak
export       BUILD_DIR=/home/kadmin/K8s-cluster-lock/build
export BOOTSTRAP_DIR=${BUILD_DIR}/keycloak-bootstrap
echo
echo ---
echo
echo Switching to context ${K8_CONTEXT}...
kubectl config use-context ${K8_CONTEXT}
echo
echo ---
echo
echo Ensuring namespace exists...
kubectl apply -f ${BOOTSTRAP_DIR}/00-namespace.yaml
echo
echo ---
echo
echo Applying bootstrap prerequisites...
kubectl apply -f ${BOOTSTRAP_DIR}/01-secret-admin.yaml
kubectl apply -f ${BOOTSTRAP_DIR}/02-secret-ldap.yaml
kubectl apply -f ${BOOTSTRAP_DIR}/03-configmap-bootstrap-script.yaml
kubectl apply -f ${BOOTSTRAP_DIR}/05-rbac.yaml
echo
echo ---
echo
echo Waiting for Keycloak workload to be ready...
if kubectl get statefulset -n ${NAMESPACE} | grep -q keycloak; then
  KEYCLOAK_STS=$(kubectl get statefulset -n ${NAMESPACE} -o jsonpath='{.items[0].metadata.name}')
  kubectl rollout status statefulset/${KEYCLOAK_STS} -n ${NAMESPACE} --timeout=600s
elif kubectl get deployment -n ${NAMESPACE} | grep -q keycloak; then
  KEYCLOAK_DEPLOY=$(kubectl get deployment -n ${NAMESPACE} -o jsonpath='{.items[0].metadata.name}')
  kubectl rollout status deployment/${KEYCLOAK_DEPLOY} -n ${NAMESPACE} --timeout=600s
else
  echo No Keycloak StatefulSet or Deployment was found in namespace ${NAMESPACE}.
  exit 1
fi
echo
echo ---
echo
echo Recreating bootstrap job...
kubectl delete job keycloak-bootstrap -n ${NAMESPACE} --ignore-not-found=true
kubectl apply -f ${BOOTSTRAP_DIR}/04-job-keycloak-bootstrap.yaml
echo
echo ---
echo
echo Waiting for bootstrap job to complete...
kubectl wait --for=condition=complete --timeout=900s job/keycloak-bootstrap -n ${NAMESPACE}
echo
echo ---
echo
echo Job logs:
kubectl logs job/keycloak-bootstrap -n ${NAMESPACE}
echo
echo ---
echo
echo Keycloak bootstrap installed.
echo
