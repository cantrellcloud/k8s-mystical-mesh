#!/usr/bin/env bash
set -euo pipefail
#clear
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export OPTIONS="/home/adminlocal/k8s-mystical-mesh/build/sites/${SITE}/${CLUSTER}-cluster"
echo
echo ---
echo
kubectl config use-context ${SITE}${CLUSTER}
echo
echo ---
echo
echo Running MongoDB Multicluster setup...
echo
kubectl mongodb multicluster setup \
  --central-cluster="j64manager" \
  --member-clusters="j64domain,j52domain,r01domain" \
  --member-cluster-namespace="mongodb" \
  --central-cluster-namespace="mongodb-operator" \
  --create-service-account-secrets \
  --install-database-roles="true" \
  --cluster-scoped="true"
echo
echo MongoDB Multicluster Setup completed.
echo