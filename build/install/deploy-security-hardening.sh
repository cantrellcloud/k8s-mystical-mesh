#!/bin/bash
# deploy-security-hardening.sh
# Deploy security hardening enhancements across all clusters
# Implementation Date: December 18, 2025

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
HELM_CHARTS_DIR="helm/packages"
SCRIPTS_DIR="build/install"

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Preflight checks
print_info "Running preflight checks..."

if ! command_exists kubectl; then
    print_error "kubectl not found. Please install kubectl."
    exit 1
fi

if ! command_exists helm; then
    print_error "helm not found. Please install helm."
    exit 1
fi

print_info "Preflight checks passed."

# Confirm deployment
echo ""
echo "=========================================="
echo "  Security Hardening Deployment"
echo "=========================================="
echo ""
echo "This script will deploy the following security hardening:"
echo "  1. Pod Security Contexts (NATS, Contour, Prometheus Stack)"
echo "  2. NetworkPolicies (Rocket.Chat, MongoDB, NATS, Monitoring)"
echo "  3. Default Deny NetworkPolicies (all application namespaces)"
echo ""
echo "⚠️  WARNING: NetworkPolicies will BLOCK all traffic by default!"
echo "    Ensure application-specific policies are in place first."
echo ""
read -p "Continue with deployment? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    print_warn "Deployment cancelled by user."
    exit 0
fi

# Step 1: Deploy NATS with Security Contexts
print_info "Step 1/9: Deploying NATS with security contexts..."

kubectl config use-context j64manager

helm upgrade nats ${HELM_CHARTS_DIR}/nats-2.12.2.tgz \
    --namespace nats-system \
    --values build/sites/all/values/nats-cluster-values-v3.yaml \
    --wait \
    --timeout 5m

print_info "Verifying NATS pods..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=nats -n nats-system --timeout=120s

print_info "Step 1/9: ✅ Complete"

# Step 2: Deploy Contour with Security Contexts (All Clusters)
print_info "Step 2/9: Deploying Contour with security contexts across all clusters..."

# j64manager
print_info "  → j64manager cluster"
kubectl config use-context j64manager
helm upgrade contour ${HELM_CHARTS_DIR}/contour-21.1.4.tgz \
    --namespace contour \
    --values build/sites/j64/manager-cluster/values/contour-values-v4.yaml \
    --wait \
    --timeout 5m

# j64domain
print_info "  → j64domain cluster"
kubectl config use-context j64domain
helm upgrade contour ${HELM_CHARTS_DIR}/contour-21.1.4.tgz \
    --namespace contour \
    --values build/sites/j64/domain-cluster/values/contour-values-v4.yaml \
    --wait \
    --timeout 5m

# j52domain
print_info "  → j52domain cluster"
kubectl config use-context j52domain
helm upgrade contour ${HELM_CHARTS_DIR}/contour-21.1.4.tgz \
    --namespace contour \
    --values build/sites/j52/domain-cluster/values/contour-values-v4.yaml \
    --wait \
    --timeout 5m

# r01domain
print_info "  → r01domain cluster"
kubectl config use-context r01domain
helm upgrade contour ${HELM_CHARTS_DIR}/contour-21.1.4.tgz \
    --namespace contour \
    --values build/sites/r01/domain-cluster/values/contour-values-v4.yaml \
    --wait \
    --timeout 5m

print_info "Step 2/9: ✅ Complete"

# Step 3: Update Prometheus Stack with Security Contexts
print_info "Step 3/9: Updating Prometheus Stack with security contexts..."

kubectl config use-context j64manager

helm upgrade prometheus ${HELM_CHARTS_DIR}/kube-prometheus-stack-80.2.0.tgz \
    --namespace monitoring \
    --values build/sites/j64/manager-cluster/values/kube-prometheus-stack-values-j64manager-v9.yaml \
    --wait \
    --timeout 10m

print_info "Verifying Prometheus, Grafana, Alertmanager pods..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n monitoring --timeout=120s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout=120s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=alertmanager -n monitoring --timeout=120s

print_info "Step 3/9: ✅ Complete"

# Step 4: Label Namespaces for NetworkPolicies
print_info "Step 4/9: Labeling namespaces for NetworkPolicy selectors..."

CLUSTERS="j64manager j64domain j52domain r01domain"
NAMESPACES="rocketchat mongodb nats-system monitoring contour istio-system kube-system"

for CLUSTER in ${CLUSTERS}; do
    kubectl config use-context ${CLUSTER}
    print_info "  → ${CLUSTER}"
    
    for NS in ${NAMESPACES}; do
        # Label namespace with its own name for selector matching
        kubectl label namespace ${NS} kubernetes.io/metadata.name=${NS} --overwrite 2>/dev/null || true
    done
done

print_info "Step 4/9: ✅ Complete"

# Step 5: Deploy Rocket.Chat NetworkPolicies
print_info "Step 5/9: Deploying Rocket.Chat NetworkPolicies..."

for CLUSTER in j64manager j64domain j52domain r01domain; do
    kubectl config use-context ${CLUSTER}
    print_info "  → Applying to ${CLUSTER}"
    kubectl apply -f build/sites/all/resources/networkpolicy-rocketchat-v1.yaml
done

print_info "Step 5/9: ✅ Complete"

# Step 6: Deploy MongoDB NetworkPolicies
print_info "Step 6/9: Deploying MongoDB NetworkPolicies..."

for CLUSTER in j64manager j64domain j52domain r01domain; do
    kubectl config use-context ${CLUSTER}
    print_info "  → Applying to ${CLUSTER}"
    kubectl apply -f build/sites/all/resources/networkpolicy-mongodb-v1.yaml
done

print_info "Step 6/9: ✅ Complete"

# Step 7: Deploy NATS NetworkPolicies
print_info "Step 7/9: Deploying NATS NetworkPolicies..."

for CLUSTER in j64manager j64domain j52domain r01domain; do
    kubectl config use-context ${CLUSTER}
    print_info "  → Applying to ${CLUSTER}"
    kubectl apply -f build/sites/all/resources/networkpolicy-nats-v1.yaml
done

print_info "Step 7/9: ✅ Complete"

# Step 8: Deploy Monitoring NetworkPolicies (j64manager only)
print_info "Step 8/9: Deploying Monitoring NetworkPolicies..."

kubectl config use-context j64manager
kubectl apply -f build/sites/j64/manager-cluster/resources/networkpolicy-monitoring-v1.yaml

print_info "Step 8/9: ✅ Complete"

# Step 9: Optionally Deploy Default Deny Policies
print_info "Step 9/9: Deploy Default Deny NetworkPolicies? (CAUTION)"
echo ""
echo "⚠️  This will block all ingress/egress by default!"
echo "    Only proceed if application-specific policies are working."
echo ""
read -p "Deploy default deny policies? (yes/no): " DEPLOY_DENY

if [ "$DEPLOY_DENY" == "yes" ]; then
    APP_NAMESPACES="rocketchat mongodb nats-system"
    
    for CLUSTER in j64manager j64domain j52domain r01domain; do
        kubectl config use-context ${CLUSTER}
        print_info "  → Applying to ${CLUSTER}"
        
        for NS in ${APP_NAMESPACES}; do
            sed "s/\${NAMESPACE}/${NS}/g" build/sites/all/resources/networkpolicy-default-deny-template.yaml | \
                kubectl apply -f -
        done
    done
    
    print_info "Step 9/9: ✅ Complete"
else
    print_warn "Step 9/9: ⏭️  Skipped (default deny not deployed)"
fi

# Verification
print_info ""
print_info "=========================================="
print_info "  Deployment Complete - Running Verification"
print_info "=========================================="
print_info ""

print_info "Checking Pod Security Contexts..."
kubectl config use-context j64manager

echo ""
echo "NATS Pod Security Context:"
kubectl get pod -n nats-system -l app.kubernetes.io/name=nats -o jsonpath='{.items[0].spec.securityContext}' | jq .

echo ""
echo "Contour Pod Security Context:"
kubectl get pod -n contour -l app.kubernetes.io/name=contour -o jsonpath='{.items[0].spec.securityContext}' | jq .

echo ""
echo "Prometheus Pod Security Context:"
kubectl get pod -n monitoring -l app.kubernetes.io/name=prometheus -o jsonpath='{.items[0].spec.securityContext}' | jq .

print_info ""
print_info "Listing NetworkPolicies..."
kubectl get networkpolicy -n rocketchat
kubectl get networkpolicy -n mongodb
kubectl get networkpolicy -n nats-system
kubectl get networkpolicy -n monitoring

echo ""
print_info "=========================================="
print_info "  ✅ Security Hardening Deployed Successfully!"
print_info "=========================================="
echo ""
echo "Security Enhancements Applied:"
echo "  ✅ Pod security contexts (runAsNonRoot, drop ALL capabilities, seccomp)"
echo "  ✅ NetworkPolicies for Rocket.Chat, MongoDB, NATS, Monitoring"
echo "  ✅ Namespace labels for policy selectors"
if [ "$DEPLOY_DENY" == "yes" ]; then
    echo "  ✅ Default deny NetworkPolicies"
else
    echo "  ⏭️  Default deny policies NOT deployed (manual step)"
fi
echo ""
echo "Next steps:"
echo "  1. Test application connectivity (Rocket.Chat, MongoDB, NATS)"
echo "  2. Review NetworkPolicy logs for blocked traffic"
echo "  3. Deploy default deny policies if not done (Step 9)"
echo "  4. Update Pod Security Standards labels (see Security-Hardening-Guide.md)"
echo ""
echo "For detailed verification steps, see: SECURITY-IMPLEMENTATION-SUMMARY.md"
echo ""

print_info "Deployment script finished."
