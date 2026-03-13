# Verify Pod 0 from cluster 1
NAMESPACE=mongodb
source_cluster="j52domain"
target_pod="echoserver0-0"
source_pod="echoserver1-0"
target_url="http://${target_pod}.${NAMESPACE}.svc.cluster.local:8080"
echo "Checking cross-cluster DNS resolution and connectivity from ${source_pod} in ${source_cluster} to ${target_pod}"
out=$(kubectl exec --context "${source_cluster}" -n ${NAMESPACE} "${source_pod}" -- \
  /bin/bash -c "curl -v ${target_url}" 2>&1);
grep "Hostname: ${target_pod}" &>/dev/null <<< "${out}" && echo "SUCCESS" || (echo "ERROR: ${out}" && return 1)

# Verify Pod 1 from cluster 0
NAMESPACE=mongodb
source_cluster="mongo0"
target_pod="echoserver1-0"
source_pod="echoserver0-0"
target_url="http://${target_pod}.${NAMESPACE}.svc.cluster.local:8080"
echo "Checking cross-cluster DNS resolution and connectivity from ${source_pod} in ${source_cluster} to ${target_pod}"
out=$(kubectl exec --context "${source_cluster}" -n ${NAMESPACE} "${source_pod}" -- \
  /bin/bash -c "curl -v ${target_url}" 2>&1);
grep "Hostname: ${target_pod}" &>/dev/null <<< "${out}" && echo "SUCCESS" || (echo "ERROR: ${out}" && return 1)

# Verify Pod 1 from cluster 2
NAMESPACE=mongodb
source_cluster="mongo2"
target_pod="echoserver1-0"
source_pod="echoserver2-0"
target_url="http://${target_pod}.${NAMESPACE}.svc.cluster.local:8080"
echo "Checking cross-cluster DNS resolution and connectivity from ${source_pod} in ${source_cluster} to ${target_pod}"
out=$(kubectl exec --context "${source_cluster}" -n ${NAMESPACE} "${source_pod}" -- \
  /bin/bash -c "curl -v ${target_url}" 2>&1);
grep "Hostname: ${target_pod}" &>/dev/null <<< "${out}" && echo "SUCCESS" || (echo "ERROR: ${out}" && return 1)

# Verify Pod 2 from cluster 0
NAMESPACE=mongodb
source_cluster="mongo0"
target_pod="echoserver2-0"
source_pod="echoserver0-0"
target_url="http://${target_pod}.${NAMESPACE}.svc.cluster.local:8080"
echo "Checking cross-cluster DNS resolution and connectivity from ${source_pod} in ${source_cluster} to ${target_pod}"
out=$(kubectl exec --context "${source_cluster}" -n ${NAMESPACE} "${source_pod}" -- \
  /bin/bash -c "curl -v ${target_url}" 2>&1);
grep "Hostname: ${target_pod}" &>/dev/null <<< "${out}" && echo "SUCCESS" || (echo "ERROR: ${out}" && return 1)
