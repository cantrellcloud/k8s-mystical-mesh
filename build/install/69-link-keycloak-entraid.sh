#!/usr/bin/env bash
# Usage: ./14-link-entra.sh <context>
# Applies the Entra ID link manifests in order
set -euo pipefail

CTX="${1:-}"

DIR="$(dirname "$0")/.."

apply() {
  kubectl ${CTX:+--context "$CTX"} apply -f "$1"
}

apply "$DIR/keycloak-entra/00-namespace.yaml"
apply "$DIR/keycloak-entra/05-rbac.yaml"
apply "$DIR/keycloak-entra/01-secret-admin.yaml"
apply "$DIR/keycloak-entra/02-secret-entra.yaml"
apply "$DIR/keycloak-entra/03-configmap-bootstrap-script.yaml"
apply "$DIR/keycloak-entra/04-job-keycloak-entra.yaml"

echo "Entra ID linking job applied. Monitor the job with:\n kubectl ${CTX:+--context $CTX} -n keycloak logs job/keycloak-entra-link"
