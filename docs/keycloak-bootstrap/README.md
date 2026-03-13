# Keycloak Bootstrap Bundle

This bundle adds a cluster-native, repeatable Keycloak bootstrap layer that matches the style of the existing `K8s-cluster-lock` install flow.

It is designed to run after your Keycloak deployment is up, using a Kubernetes `Job` and `kcadm.sh` from the Keycloak container image.

## Included files

```text
build/keycloak-bootstrap/
  00-namespace.yaml
  01-secret-admin.yaml
  02-secret-ldap.yaml
  03-configmap-bootstrap-script.yaml
  04-job-keycloak-bootstrap.yaml
  05-rbac.yaml

build/install/
  11-bootstrap-keycloak.sh

docs/keycloak-bootstrap/
  README.md
```

## What it does

The bootstrap job:
- authenticates to Keycloak with admin credentials
- creates the target realm if it does not already exist
- creates LDAP federation to `cantrelloffice.cloud`
- creates bootstrap-managed realm roles:
  - `pihole_access`
  - `longhorn_access`
  - `grafana_access`
  - `prometheus_access`
  - `alertmanager_access`
- creates or updates confidential OIDC clients for:
  - Pi-hole
  - Longhorn
  - Grafana
  - Prometheus
  - Alertmanager
- adds an audience mapper for each client so `oauth2-proxy` can validate the token audience cleanly

## Best-practice notes

- Secrets are kept in Kubernetes `Secret` objects, not hard-coded in scripts.
- The bootstrap job uses the same Keycloak image family as the deployed server, which avoids CLI/server drift.
- The install script uses `kubectl apply` for idempotent re-runs.
- The job waits for Keycloak to become reachable before making admin API calls.
- LDAP federation is configured read-only, which is the right default for your setup.

## Before running

Update at minimum:
- `build/keycloak-bootstrap/01-secret-admin.yaml`
  - `KC_ADMIN_PASSWORD`
  - `KC_TARGET_REALM` if you do not want `lab`
  - `KC_URL` if your Keycloak URL changes
- `build/keycloak-bootstrap/02-secret-ldap.yaml`
  - `LDAP_BIND_CREDENTIAL`
  - `LDAP_CONNECTION_URL` if you want a different DC
  - `LDAP_BIND_DN` if the service account DN changes
  - `LDAP_USERS_DN` if the sync OU changes

## How to run

```bash
chmod +x build/install/11-bootstrap-keycloak.sh
./build/install/11-bootstrap-keycloak.sh copine-k801
```

## Validation

```bash
kubectl get jobs -n keycloak
kubectl logs job/keycloak-bootstrap -n keycloak
```

Check the realm and LDAP provider:
```bash
kubectl exec -it -n keycloak <keycloak-pod> -- /opt/keycloak/bin/kcadm.sh get realms
kubectl exec -it -n keycloak <keycloak-pod> -- /opt/keycloak/bin/kcadm.sh get user-storage -r lab
```
