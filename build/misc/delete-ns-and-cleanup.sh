#!/usr/bin/env bash
rm ~/k8s-mystical-mesh/build/sites/j64/manager-cluster/token*.txt

kubectl delete ns mongodb          --context j64manager
kubectl delete ns mongodb-operator --context j64manager
#kubectl delete ns istio-system     --context j64manager
kubectl delete ns mongodb          --context j64domain
kubectl delete ns mongodb-operator --context j64domain
#kubectl delete ns istio-system     --context j64domain
kubectl delete ns mongodb          --context j52domain
kubectl delete ns mongodb-operator --context j52domain
#kubectl delete ns istio-system     --context j52domain
kubectl delete ns mongodb          --context r01domain
kubectl delete ns mongodb-operator --context r01domain
#kubectl delete ns istio-system     --context r01domain

kubectl delete clusterrole --context j64manager mongodb-kubernetes-operator-j64manager-cluster-role
kubectl delete clusterrole --context j64manager mongodb-kubernetes-operator-multi-cluster-role
kubectl delete clusterrole --context j64manager mongodb-kubernetes-operator-multi-cluster-role-telemetry

kubectl delete clusterrole --context j64domain mongodb-kubernetes-operator-j64domain-cluster-role
kubectl delete clusterrole --context j64domain mongodb-kubernetes-operator-multi-cluster-role
kubectl delete clusterrole --context j64domain mongodb-kubernetes-operator-multi-cluster-role-telemetry

kubectl delete clusterrole --context j52domain mongodb-kubernetes-operator-j52domain-cluster-role
kubectl delete clusterrole --context j52domain mongodb-kubernetes-operator-multi-cluster-role
kubectl delete clusterrole --context j52domain mongodb-kubernetes-operator-multi-cluster-role-telemetry

kubectl delete clusterrole --context r01domain mongodb-kubernetes-operator-r01domain-cluster-role
kubectl delete clusterrole --context r01domain mongodb-kubernetes-operator-multi-cluster-role
kubectl delete clusterrole --context r01domain mongodb-kubernetes-operator-multi-cluster-role-telemetry

kubectl delete clusterrolebinding --context j64manager mongodb-kubernetes-operator-j64manager-cluster-binding
kubectl delete clusterrolebinding --context j64manager mongodb-kubernetes-operator-multi-cluster-role-binding
kubectl delete clusterrolebinding --context j64manager mongodb-kubernetes-operator-multi-telemetry-cluster-role-binding

kubectl delete clusterrolebinding --context j64domain mongodb-kubernetes-operator-j64domain-cluster-binding
kubectl delete clusterrolebinding --context j64domain mongodb-kubernetes-operator-multi-cluster-role-binding
kubectl delete clusterrolebinding --context j64domain mongodb-kubernetes-operator-multi-telemetry-cluster-role-binding

kubectl delete clusterrolebinding --context j52domain mongodb-kubernetes-operator-j52domain-cluster-binding
kubectl delete clusterrolebinding --context j52domain mongodb-kubernetes-operator-multi-cluster-role-binding
kubectl delete clusterrolebinding --context j52domain mongodb-kubernetes-operator-multi-telemetry-cluster-role-binding

kubectl delete clusterrolebinding --context r01domain mongodb-kubernetes-operator-r01domain-cluster-binding
kubectl delete clusterrolebinding --context r01domain mongodb-kubernetes-operator-multi-cluster-role-binding
kubectl delete clusterrolebinding --context r01domain mongodb-kubernetes-operator-multi-telemetry-cluster-role-binding
