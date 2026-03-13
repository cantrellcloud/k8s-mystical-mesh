#!/usr/bin/env bash
set -euo pipefail

# ===== your original exports (kept) =====
export MDB_GKE_PROJECT="preprod"
export K8S_MANAGEMENT_CLUSTER="j64manager"
export K8S_CLUSTER_0="j64domain"
export K8S_CLUSTER_1="j52domain"
export K8S_CLUSTER_2="r01domain"
export K8S_TEST_NAMESPACE="echotest"

# ----- if you installed Istio with a revision, set it here; else leave empty
ISTIO_REV="stable"   # e.g., "stable" or ""

contexts=("$K8S_MANAGEMENT_CLUSTER" "$K8S_CLUSTER_0" "$K8S_CLUSTER_1" "$K8S_CLUSTER_2")

echo "== 0) Prep namespaces for sidecar injection =="
for ctx in "${contexts[@]}"; do
  kubectl --context "$ctx" get ns "$K8S_TEST_NAMESPACE" >/dev/null 2>&1 || \
    kubectl --context "$ctx" create ns "$K8S_TEST_NAMESPACE"
  if [[ -n "$ISTIO_REV" ]]; then
    kubectl --context "$ctx" label ns "$K8S_TEST_NAMESPACE" istio.io/rev="$ISTIO_REV" --overwrite
  else
    kubectl --context "$ctx" label ns "$K8S_TEST_NAMESPACE" istio.io/rev=stable --overwrite
  fi

kubectl --context "$ctx" label --overwrite namespace "$K8S_TEST_NAMESPACE" pod-security.kubernetes.io/enforce=privileged
kubectl --context "$ctx" label --overwrite namespace "$K8S_TEST_NAMESPACE" pod-security.kubernetes.io/audit=privileged
kubectl --context "$ctx" label --overwrite namespace "$K8S_TEST_NAMESPACE" pod-security.kubernetes.io/warn=privileged

done
echo ---
echo
echo "== 1) Deploy echoservers (one per cluster) =="
echo
echo "$K8S_MANAGEMENT_CLUSTER-cluster"
kubectl apply --context "$K8S_MANAGEMENT_CLUSTER" -n "$K8S_TEST_NAMESPACE" -f - <<'EOF'
apiVersion: apps/v1
kind: StatefulSet
metadata: { name: echoserver0 }
spec:
  replicas: 1
  selector: { matchLabels: { app: echoserver0 } }
  serviceName: echoserver
  template:
    metadata: { labels: { app: echoserver0 } }
    spec:
      containers:
      - name: echoserver0
        image: altregistry.dev.kube:8443/library/corelab/echoserver:1.10
        imagePullPolicy: Always
        ports: [{ containerPort: 8080, name: http }]
EOF
echo
echo "$K8S_CLUSTER_0-cluster"
kubectl apply --context "$K8S_CLUSTER_0" -n "$K8S_TEST_NAMESPACE" -f - <<'EOF'
apiVersion: apps/v1
kind: StatefulSet
metadata: { name: echoserver1 }
spec:
  replicas: 1
  selector: { matchLabels: { app: echoserver1 } }
  serviceName: echoserver
  template:
    metadata: { labels: { app: echoserver1 } }
    spec:
      containers:
      - name: echoserver1
        image: altregistry.dev.kube:8443/library/corelab/echoserver:1.10
        imagePullPolicy: Always
        ports: [{ containerPort: 8080, name: http }]
EOF
echo
echo "$K8S_CLUSTER_1-cluster"
kubectl apply --context "$K8S_CLUSTER_1" -n "$K8S_TEST_NAMESPACE" -f - <<'EOF'
apiVersion: apps/v1
kind: StatefulSet
metadata: { name: echoserver2 }
spec:
  replicas: 1
  selector: { matchLabels: { app: echoserver2 } }
  serviceName: echoserver
  template:
    metadata: { labels: { app: echoserver2 } }
    spec:
      containers:
      - name: echoserver2
        image: altregistry.dev.kube:8443/library/corelab/echoserver:1.10
        imagePullPolicy: Always
        ports: [{ containerPort: 8080, name: http }]
EOF
echo
echo "$K8S_CLUSTER_2-cluster"
kubectl apply --context "$K8S_CLUSTER_2" -n "$K8S_TEST_NAMESPACE" -f - <<'EOF'
apiVersion: apps/v1
kind: StatefulSet
metadata: { name: echoserver3 }
spec:
  replicas: 1
  selector: { matchLabels: { app: echoserver3 } }
  serviceName: echoserver
  template:
    metadata: { labels: { app: echoserver3 } }
    spec:
      containers:
      - name: echoserver3
        image: altregistry.dev.kube:8443/library/corelab/echoserver:1.10
        imagePullPolicy: Always
        ports: [{ containerPort: 8080, name: http }]
EOF

# Wait ready
kubectl wait --context "$K8S_MANAGEMENT_CLUSTER" -n "$K8S_TEST_NAMESPACE" \
   --for=condition=ready pod -l statefulset.kubernetes.io/pod-name=echoserver0-0 --timeout=90s
kubectl wait --context "$K8S_CLUSTER_0" -n "$K8S_TEST_NAMESPACE" \
   --for=condition=ready pod -l statefulset.kubernetes.io/pod-name=echoserver1-0 --timeout=90s
kubectl wait --context "$K8S_CLUSTER_1" -n "$K8S_TEST_NAMESPACE" \
   --for=condition=ready pod -l statefulset.kubernetes.io/pod-name=echoserver2-0 --timeout=90s
kubectl wait --context "$K8S_CLUSTER_2" -n "$K8S_TEST_NAMESPACE" \
   --for=condition=ready pod -l statefulset.kubernetes.io/pod-name=echoserver3-0 --timeout=90s

echo
echo ---
echo
echo "== 2) Create stable Service name 'echoserver' in each cluster =="
# Make it HTTP-named so Istio recognizes protocol
for idx in 0 1 2 3; do
  ctx="${contexts[$idx]}"
  app="echoserver${idx}"
  kubectl apply --context "$ctx" -n "$K8S_TEST_NAMESPACE" -f - <<EOF
apiVersion: v1
kind: Service
metadata: { name: echoserver }
spec:
  ports:
  - name: http
    port: 8080
    targetPort: 8080
    protocol: TCP
  selector: { app: ${app} }
EOF
done

echo
echo ---
echo
echo "== 3) Deploy a curl client ('sleep') in j64domain to generate traffic =="
kubectl apply --context "$K8S_CLUSTER_0" -n "$K8S_TEST_NAMESPACE" -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata: { name: sleep }
spec:
  replicas: 1
  selector: { matchLabels: { app: sleep } }
  template:
    metadata: { labels: { app: sleep } }
    spec:
      containers:
      - name: curl
        image: altregistry.dev.kube:8443/library/curlimages/curl:8.8.0
        command: ["sleep","3650d"]
EOF
kubectl wait --context "$K8S_CLUSTER_0" -n "$K8S_TEST_NAMESPACE" \
  --for=condition=available deploy/sleep --timeout=90s
SLEEP_POD="$(kubectl --context "$K8S_CLUSTER_0" -n "$K8S_TEST_NAMESPACE" get pod -l app=sleep -o jsonpath='{.items[0].metadata.name}')"

echo
echo ---
echo
echo "== 4) Baseline: call the service name (should hit local first, then remote if local is down) =="
kubectl --context "$K8S_CLUSTER_0" -n "$K8S_TEST_NAMESPACE" exec "$SLEEP_POD" -c curl -- \
  sh -lc 'for i in $(seq 1 5); do echo -n "$i "; curl -sS --max-time 3 http://echoserver:8080/ | head -n1; echo; done'

echo
echo ---
echo
echo "== 5) Prove cross-cluster: scale local to 0 and call again (should still succeed via east-west) =="
kubectl --context "$K8S_CLUSTER_0" -n "$K8S_TEST_NAMESPACE" scale statefulset echoserver1 --replicas=0
sleep 5
kubectl --context "$K8S_CLUSTER_0" -n "$K8S_TEST_NAMESPACE" exec "$SLEEP_POD" -c curl -- \
  sh -lc 'for i in $(seq 1 5); do echo -n "$i "; curl -sS --max-time 5 http://echoserver:8080/ | head -n1; echo; done'

echo
echo ---
echo
echo "== 6) Introspection: confirm remote endpoints + 15443 clusters exist in the sidecar =="
# Requires istioctl on PATH and KUBECONFIG pointing to j64domain
kubectl --context "$K8S_CLUSTER_0" -n "$K8S_TEST_NAMESPACE" get pod "$SLEEP_POD" >/dev/null
echo
echo "--- proxy-config endpoints (look for remote endpoints / network metadata) ---"
istioctl --context "$K8S_CLUSTER_0" proxy-config endpoints "$SLEEP_POD" -n "$K8S_TEST_NAMESPACE" | grep -E 'echoserver|15443|jw|j52|r01' || true
echo
echo "--- proxy-config clusters (look for outbound|15443|| entries) ---"
istioctl --context "$K8S_CLUSTER_0" proxy-config clusters "$SLEEP_POD" -n "$K8S_TEST_NAMESPACE" | grep 15443 || true

echo
echo ---
echo
echo "== 7) Restore local and show load distribution again =="
kubectl --context "$K8S_CLUSTER_0" -n "$K8S_TEST_NAMESPACE" scale statefulset echoserver1 --replicas=1
kubectl wait --context "$K8S_CLUSTER_0" -n "$K8S_TEST_NAMESPACE" \
  --for=condition=ready pod -l statefulset.kubernetes.io/pod-name=echoserver1-0 --timeout=90s
kubectl --context "$K8S_CLUSTER_0" -n "$K8S_TEST_NAMESPACE" exec "$SLEEP_POD" -c curl -- \
  sh -lc 'for i in $(seq 1 5); do echo -n "$i "; curl -sS --max-time 3 http://echoserver:8080/ | head -n1; echo; done'

echo
echo ---
echo
echo "✅ Mesh looks healthy if: baseline worked, cross-cluster calls worked with local=0, and 15443 clusters/endpoints are present."
