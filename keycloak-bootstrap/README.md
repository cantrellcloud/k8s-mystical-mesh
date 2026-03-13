# Keycloak Bootstrap

This folder contains Kubernetes manifests used to bootstrap Keycloak during cluster setup.

Overview
- Purpose: Create the namespace, secrets, ConfigMap (bootstrap script), RBAC, and a Job that runs the bootstrap steps to initialize Keycloak with an admin account and optional LDAP credentials.
- Apply order: Namespace -> Secrets -> ConfigMap -> RBAC -> Job

Files
- [keycloak-bootstrap/00-namespace.yaml](keycloak-bootstrap/00-namespace.yaml): Creates the Kubernetes namespace used by Keycloak bootstrap resources. Apply this first so subsequent resources are created in the correct namespace.

- [keycloak-bootstrap/01-secret-admin.yaml](keycloak-bootstrap/01-secret-admin.yaml): Contains the admin credentials used by the bootstrap Job to create the initial Keycloak admin user. This is a Kubernetes Secret (type: Opaque). Replace the placeholder values with secure values or create the secret using `kubectl create secret`.

- [keycloak-bootstrap/02-secret-ldap.yaml](keycloak-bootstrap/02-secret-ldap.yaml): Optional LDAP credentials secret used by the bootstrap Job if LDAP configuration/import is required. Keep sensitive values secure and prefer creating this secret from the command line instead of storing plain text in YAML.

- [keycloak-bootstrap/03-configmap-bootstrap-script.yaml](keycloak-bootstrap/03-configmap-bootstrap-script.yaml): A ConfigMap that holds the bootstrap script (shell script or commands) executed by the `Job`. Review the script to understand what actions are performed (creating realms, clients, users, roles, importing JSON, etc.). Modify the script if you need custom realm or client configuration.

- [keycloak-bootstrap/04-job-keycloak-bootstrap.yaml](keycloak-bootstrap/04-job-keycloak-bootstrap.yaml): A Kubernetes `Job` that mounts the ConfigMap and Secrets and runs the bootstrap script against the Keycloak endpoint. It typically uses a small image with `curl`/`jq`/`kc` tooling to interact with the Keycloak Admin REST API.

- [keycloak-bootstrap/05-rbac.yaml](keycloak-bootstrap/05-rbac.yaml): RBAC resources required by the Job (ServiceAccount, Role/ClusterRole, RoleBinding/ClusterRoleBinding). Ensure RBAC grants just enough permissions for the bootstrap Job to run (reading secrets, listing pods if necessary, etc.).

Prerequisites
- A running Keycloak instance reachable from the cluster (or ensure the bootstrap Job can access Keycloak service). The bootstrap Job assumes the Keycloak service exists and is addressable.
- Access to create namespaces, secrets, ConfigMaps, RBAC, and Jobs in the cluster.
- Secrets should contain correct credentials (admin username/password, LDAP credentials if used).

Best practices for secrets
- Do not commit real credentials to source control. Replace values in `01-secret-admin.yaml` and `02-secret-ldap.yaml` with placeholders or remove them and create secrets with `kubectl`:

```bash
kubectl create secret generic keycloak-admin --from-literal=ADMIN_USERNAME=admin --from-literal=ADMIN_PASSWORD='S3cureP@ss' -n keycloak
kubectl create secret generic keycloak-ldap --from-literal=LDAP_BIND_DN='cn=bind,dc=example,dc=org' --from-literal=LDAP_BIND_PASSWORD='ldap-secret' -n keycloak
```

Applying the bootstrap
1. Create the namespace:

```bash
kubectl apply -f keycloak-bootstrap/00-namespace.yaml
```

2. Create secrets (recommended):

```bash
kubectl apply -f keycloak-bootstrap/01-secret-admin.yaml
# or use kubectl create secret as shown above
```

3. Create the LDAP secret if needed:

```bash
kubectl apply -f keycloak-bootstrap/02-secret-ldap.yaml
```

4. Apply the ConfigMap and RBAC:

```bash
kubectl apply -f keycloak-bootstrap/03-configmap-bootstrap-script.yaml
kubectl apply -f keycloak-bootstrap/05-rbac.yaml
```

5. Run the Job:

```bash
kubectl apply -f keycloak-bootstrap/04-job-keycloak-bootstrap.yaml
```

Verification
- Check Job status:

```bash
kubectl get jobs -n keycloak
kubectl describe job keycloak-bootstrap -n keycloak
```

- Inspect Job pod logs to confirm bootstrap actions completed successfully:

```bash
kubectl logs -l job-name=keycloak-bootstrap -n keycloak
```

- Verify Keycloak admin user exists by logging into the Keycloak web UI or calling the Admin API.

Cleanup and idempotency
- The Job may be designed to be idempotent; review the bootstrap script to confirm it safely re-runs without duplicating resources.
- To re-run the Job, delete completed pods and the Job resource then re-apply the Job YAML or create a new Job run with a new name.

```bash
kubectl delete job keycloak-bootstrap -n keycloak
kubectl apply -f keycloak-bootstrap/04-job-keycloak-bootstrap.yaml
```

Notes and customization
- Edit the ConfigMap script to add realm/json imports, create clients, or configure LDAP mappers.
- If Keycloak is not reachable via service DNS during bootstrap, consider running the Job with init steps or waiting for Keycloak readiness (the script can poll the endpoint until available).
- If running in a restricted environment, ensure the Job's ServiceAccount has minimal permissions needed; avoid granting cluster-admin.

Contact / Troubleshooting
- If the Job fails, check the pod logs and the bootstrap script in the ConfigMap to identify the failing step.
- Ensure secrets are present and correct, and Keycloak admin credentials match what the script expects.
