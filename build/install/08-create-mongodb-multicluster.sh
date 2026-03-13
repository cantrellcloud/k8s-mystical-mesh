#!/usr/bin/env bash
set -euo pipefail
#clear
echo
echo Exporting variables...
export SITE=${1}
export CLUSTER=${2}
export OPTIONS="/home/adminlocal/k8s-mystical-mesh/build/sites/${SITE}/${CLUSTER}-cluster"
export TOKEN_DIR="/home/adminlocal/k8s-mystical-mesh/build/misc/sa-tokens"
echo
echo ---
echo
kubectl config use-context ${SITE}${CLUSTER}
echo
echo ---
echo
echo Setting up MongoDBMultiCluster Namespaces, SA, Roles, and Bindings
echo
echo Create and label namespaces...
echo
kubectl --context j64manager get ns mongodb-operator >/dev/null 2>&1 || kubectl --context j64manager create namespace mongodb-operator
kubectl --context j64manager label --overwrite namespace mongodb-operator istio.io/rev=stable
kubectl --context j64manager label --overwrite namespace mongodb-operator kubernetes.io/metadata.name=mongodb-operator
#kubectl --context j64manager label --overwrite namespace mongodb-operator pod-security.kubernetes.io/enforce=privileged
#kubectl --context j64manager label --overwrite namespace mongodb-operator pod-security.kubernetes.io/audit=privileged
#kubectl --context j64manager label --overwrite namespace mongodb-operator pod-security.kubernetes.io/warn=privileged

kubectl --context j64manager get ns mongodb >/dev/null 2>&1 || kubectl --context j64manager create namespace mongodb
kubectl --context j64manager label --overwrite namespace mongodb istio.io/rev=stable
kubectl --context j64manager label --overwrite namespace mongodb-operator kubernetes.io/metadata.name=mongodb-operator
#kubectl --context j64manager label --overwrite namespace mongodb pod-security.kubernetes.io/enforce=privileged
#kubectl --context j64manager label --overwrite namespace mongodb pod-security.kubernetes.io/audit=privileged
#kubectl --context j64manager label --overwrite namespace mongodb pod-security.kubernetes.io/warn=privileged

kubectl --context j64domain get ns mongodb-operator >/dev/null 2>&1 || kubectl --context j64domain create namespace mongodb-operator
kubectl --context j64domain label --overwrite namespace mongodb-operator istio.io/rev=stable
kubectl --context j64manager label --overwrite namespace mongodb-operator kubernetes.io/metadata.name=mongodb-operator
#kubectl --context j64domain label --overwrite namespace mongodb-operator pod-security.kubernetes.io/enforce=privileged
#kubectl --context j64domain label --overwrite namespace mongodb-operator pod-security.kubernetes.io/audit=privileged
#kubectl --context j64domain label --overwrite namespace mongodb-operator pod-security.kubernetes.io/warn=privileged

kubectl --context j64domain get ns mongodb >/dev/null 2>&1 || kubectl --context j64domain create namespace mongodb
kubectl --context j64domain label --overwrite namespace mongodb istio.io/rev=stable
kubectl --context j64manager label --overwrite namespace mongodb-operator kubernetes.io/metadata.name=mongodb-operator
#kubectl --context j64domain label --overwrite namespace mongodb pod-security.kubernetes.io/enforce=privileged
#kubectl --context j64domain label --overwrite namespace mongodb pod-security.kubernetes.io/audit=privileged
#kubectl --context j64domain label --overwrite namespace mongodb pod-security.kubernetes.io/warn=privileged

kubectl --context j52domain get ns mongodb-operator >/dev/null 2>&1 || kubectl --context j52domain create namespace mongodb-operator
kubectl --context j52domain label --overwrite namespace mongodb-operator istio.io/rev=stable
kubectl --context j64manager label --overwrite namespace mongodb-operator kubernetes.io/metadata.name=mongodb-operator
#kubectl --context j52domain label --overwrite namespace mongodb-operator pod-security.kubernetes.io/enforce=privileged
#kubectl --context j52domain label --overwrite namespace mongodb-operator pod-security.kubernetes.io/audit=privileged
#kubectl --context j52domain label --overwrite namespace mongodb-operator pod-security.kubernetes.io/warn=privileged

kubectl --context j52domain get ns mongodb >/dev/null 2>&1 || kubectl --context j52domain create namespace mongodb
kubectl --context j52domain label --overwrite namespace mongodb istio.io/rev=stable
kubectl --context j64manager label --overwrite namespace mongodb-operator kubernetes.io/metadata.name=mongodb-operator
#kubectl --context j52domain label --overwrite namespace mongodb pod-security.kubernetes.io/enforce=privileged
#kubectl --context j52domain label --overwrite namespace mongodb pod-security.kubernetes.io/audit=privileged
#kubectl --context j52domain label --overwrite namespace mongodb pod-security.kubernetes.io/warn=privileged

kubectl --context r01domain get ns mongodb-operator >/dev/null 2>&1 || kubectl --context r01domain create namespace mongodb-operator
kubectl --context r01domain label --overwrite namespace mongodb-operator istio.io/rev=stable
kubectl --context j64manager label --overwrite namespace mongodb-operator kubernetes.io/metadata.name=mongodb-operator
#kubectl --context r01domain label --overwrite namespace mongodb-operator pod-security.kubernetes.io/enforce=privileged
#kubectl --context r01domain label --overwrite namespace mongodb-operator pod-security.kubernetes.io/audit=privileged
#kubectl --context r01domain label --overwrite namespace mongodb-operator pod-security.kubernetes.io/warn=privileged

kubectl --context r01domain get ns mongodb >/dev/null 2>&1 || kubectl --context r01domain create namespace mongodb
kubectl --context r01domain label --overwrite namespace mongodb istio.io/rev=stable
kubectl --context j64manager label --overwrite namespace mongodb-operator kubernetes.io/metadata.name=mongodb-operator
#kubectl --context r01domain label --overwrite namespace mongodb pod-security.kubernetes.io/enforce=privileged
#kubectl --context r01domain label --overwrite namespace mongodb pod-security.kubernetes.io/audit=privileged
#kubectl --context r01domain label --overwrite namespace mongodb pod-security.kubernetes.io/warn=privileged
echo
echo ---
echo
: <<'COMMENT'
echo Create MongodDB Operator service accounts...
echo
# mongodb-kubernetes-operator-j64manager-serviceaccount
kubectl --context j64manager -n mongodb-operator get serviceaccount mongodb-kubernetes-operator-j64manager-cluster-sa >/dev/null 2>&1 || \
  kubectl --context j64manager -n mongodb-operator create -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: mongodb-kubernetes-operator-j64manager-cluster-sa
  namespace: mongodb-operator
EOF
#kubectl --context j64manager -n mongodb-operator create -f - <<EOF
#apiVersion: rbac.authorization.k8s.io/v1
#kind: ClusterRole
#metadata:
#  name: mongodb-kubernetes-operator-j64manager-cluster-role
#  namespace: mongodb-operator
#rules:
#- apiGroups:
#  - ""
#  - "apps"
#  - "mongodb.com"
#  - "batch"
#  resources:
#  - "*"
#  verbs:
#  - get
#  - list
#  - watch
#  - create
#  - update
#  - patch
#  - delete
#EOF
kubectl --context j64manager -n mongodb-operator get clusterrolebinding mongodb-kubernetes-operator-j64manager-cluster-binding >/dev/null 2>&1 || \
 kubectl --context j64manager -n mongodb-operator create -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: mongodb-kubernetes-operator-j64manager-cluster-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: mongodb-kubernetes-operator-j64manager-cluster-sa
  namespace: mongodb-operator
EOF
# mongodb-kubernetes-operator-j64domain-cluster-serviceaccount
kubectl --context j64domain -n mongodb-operator get serviceaccount mongodb-kubernetes-operator-j64domain-cluster-sa >/dev/null 2>&1 || \
 kubectl --context j64domain -n mongodb-operator create -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: mongodb-kubernetes-operator-j64domain-cluster-sa
  namespace: mongodb-operator
EOF
#kubectl --context j64domain -n mongodb-operator create -f - <<EOF
#apiVersion: rbac.authorization.k8s.io/v1
#kind: ClusterRole
#metadata:
#  name: mongodb-kubernetes-operator-j64domain-cluster-role
#  namespace: mongodb-operator
#rules:
#- apiGroups:
#  - ""
#  - "apps"
#  - "mongodb.com"
#  - "batch"
#  resources:
#  - "*"
#  verbs:
#  - get
#  - list
#  - watch
#  - create
#  - update
#  - patch
#  - delete
#EOF
kubectl --context j64domain -n mongodb-operator get clusterrolebinding mongodb-kubernetes-operator-j64domain-cluster-binding >/dev/null 2>&1 || \
 kubectl --context j64domain -n mongodb-operator create -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: mongodb-kubernetes-operator-j64domain-cluster-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: mongodb-kubernetes-operator-j64domain-cluster-sa
  namespace: mongodb-operator
EOF
# mongodb-kubernetes-operator-j52domain-cluster-serviceaccount
kubectl --context j52domain -n mongodb-operator get serviceaccount mongodb-kubernetes-operator-j52domain-cluster-sa >/dev/null 2>&1 || \
 kubectl --context j52domain -n mongodb-operator create -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: mongodb-kubernetes-operator-j52domain-cluster-sa
  namespace: mongodb-operator
EOF
#kubectl --context j52domain -n mongodb-operator create -f - <<EOF
#apiVersion: rbac.authorization.k8s.io/v1
#kind: ClusterRole
#metadata:
#  name: mongodb-kubernetes-operator-j52domain-cluster-role
#  namespace: mongodb-operator
#rules:
#- apiGroups:
#  - ""
#  - "apps"
#  - "mongodb.com"
#  - "batch"
#  resources:
#  - "*"
#  verbs:
#  - get
#  - list
#  - watch
#  - create
#  - update
#  - patch
#  - delete
#EOF
kubectl --context j52domain -n mongodb-operator get clusterrolebinding mongodb-kubernetes-operator-j52domain-cluster-binding >/dev/null 2>&1 || \
 kubectl --context j52domain -n mongodb-operator create -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: mongodb-kubernetes-operator-j52domain-cluster-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: mongodb-kubernetes-operator-j52domain-cluster-sa
  namespace: mongodb-operator
EOF
# mongodb-kubernetes-operator-r01domain-cluster-serviceaccount
kubectl --context r01domain -n mongodb-operator get serviceaccount mongodb-kubernetes-operator-r01domain-cluster-sa >/dev/null 2>&1 || \
 kubectl --context r01domain -n mongodb-operator create -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: mongodb-kubernetes-operator-r01domain-cluster-sa
  namespace: mongodb-operator
EOF
#kubectl --context r01domain -n mongodb-operator create -f - <<EOF
#apiVersion: rbac.authorization.k8s.io/v1
#kind: ClusterRole
#metadata:
#  name: mongodb-kubernetes-operator-r01domain-cluster-role
#  namespace: mongodb-operator
#rules:
#- apiGroups:
#  - ""
#  - "apps"
#  - "mongodb.com"
#  - "batch"
#  resources:
#  - "*"
#  verbs:
#  - get
#  - list
#  - watch
#  - create
#  - update
#  - patch
#  - delete
#EOF
kubectl --context r01domain -n mongodb-operator get clusterrolebinding mongodb-kubernetes-operator-r01domain-cluster-binding >/dev/null 2>&1 || \
 kubectl --context r01domain -n mongodb-operator create -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: mongodb-kubernetes-operator-r01domain-cluster-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: mongodb-kubernetes-operator-r01domain-cluster-sa
  namespace: mongodb-operator
EOF
echo
echo ---
echo
echo Creating service account tokens...
echo
kubectl --context j64manager -n mongodb-operator get secret mongodb-kubernetes-operator-j64manager-cluster-sa-token >/dev/null 2>&1 || \
 kubectl --context j64manager -n mongodb-operator create -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  annotations:
    kubernetes.io/service-account.name: mongodb-kubernetes-operator-j64manager-cluster-sa
  name: mongodb-kubernetes-operator-j64manager-cluster-sa-token
  namespace: mongodb-operator
type: kubernetes.io/service-account-token
EOF
kubectl --context j64domain -n mongodb-operator get secret mongodb-kubernetes-operator-j64domain-cluster-sa-token >/dev/null 2>&1 || \
  kubectl --context j64domain -n mongodb-operator create -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  annotations:
    kubernetes.io/service-account.name: mongodb-kubernetes-operator-j64domain-cluster-sa
  name: mongodb-kubernetes-operator-j64domain-cluster-sa-token
  namespace: mongodb-operator
type: kubernetes.io/service-account-token
EOF
kubectl --context j52domain -n mongodb-operator get secret mongodb-kubernetes-operator-j52domain-cluster-sa-token >/dev/null 2>&1 || \
  kubectl --context j52domain -n mongodb-operator create -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  annotations:
    kubernetes.io/service-account.name: mongodb-kubernetes-operator-j52domain-cluster-sa
  name: mongodb-kubernetes-operator-j52domain-cluster-sa-token
  namespace: mongodb-operator
type: kubernetes.io/service-account-token
EOF
kubectl --context r01domain -n mongodb-operator get secret mongodb-kubernetes-operator-r01domain-cluster-sa-token >/dev/null 2>&1 || \
  kubectl --context r01domain -n mongodb-operator create -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  annotations:
    kubernetes.io/service-account.name: mongodb-kubernetes-operator-r01domain-cluster-sa
  name: mongodb-kubernetes-operator-r01domain-cluster-sa-token
  namespace: mongodb-operator
type: kubernetes.io/service-account-token
EOF
echo
echo ---
echo
echo Get and save service account tokens...
echo
mkdir -p ${TOKEN_DIR}
kubectl --context j64manager -n mongodb-operator get secret mongodb-kubernetes-operator-j64manager-cluster-sa-token -o yaml -o jsonpath="{.data.token}" | base64 -d > ${TOKEN_DIR}/token-j64manager-sa.txt
kubectl --context j64domain -n mongodb-operator get secret mongodb-kubernetes-operator-j64domain-cluster-sa-token -o yaml -o jsonpath="{.data.token}" | base64 -d > ${TOKEN_DIR}/token-j64domain-sa.txt
kubectl --context j52domain -n mongodb-operator get secret mongodb-kubernetes-operator-j52domain-cluster-sa-token -o yaml -o jsonpath="{.data.token}" | base64 -d > ${TOKEN_DIR}/token-j52domain-sa.txt
kubectl --context r01domain -n mongodb-operator get secret mongodb-kubernetes-operator-r01domain-cluster-sa-token -o yaml -o jsonpath="{.data.token}" | base64 -d > ${TOKEN_DIR}/token-r01domain-sa.txt
echo
COMMENT
echo ---
echo
echo MongoDB Multicluster Service Account Setup completed.
echo
