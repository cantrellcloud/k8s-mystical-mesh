# Keycloak Entra ID Integration (OIDC Broker)

This bundle provides a repeatable way to configure Keycloak to authenticate users via Microsoft Entra ID (formerly Azure AD) using OpenID Connect.  It complements your existing Keycloak deployment by creating an OIDC identity provider in a specified realm, plus protocol mappers for group and object ID claims.

## Contents

- `build/keycloak-entra/00-namespace.yaml` – ensures the `keycloak` namespace exists (safe to re‑apply).
- `build/keycloak-entra/01-secret-admin.yaml` – template secret containing your Keycloak admin credentials and realm settings.
- `build/keycloak-entra/02-secret-entra.yaml` – template secret containing your Azure Entra tenant ID, client ID, and client secret.
- `build/keycloak-entra/03-configmap-bootstrap-script.yaml` – stores the `entra-link.sh` script to create or update the identity provider and mappers.
- `build/keycloak-entra/04-job-keycloak-entra.yaml` – Kubernetes Job that runs the script using the official Keycloak image.
- `build/keycloak-entra/05-rbac.yaml` – service account and Role/RoleBinding so the job can mount secrets.
- `build/install/14-link-entra.sh` – convenience script to apply the manifests in order.

## Pre‑requisites

1. **Keycloak deployed** in the `keycloak` namespace and reachable via `KC_URL`.
2. **Keycloak Admin credentials** for realm master administration.
3. **Azure Entra ID tenant and app registration**:
   - A **tenant ID** (GUID).
   - A registered **application** (client) with:
     - Redirect URI: `https://<your-keycloak-host>/realms/<realm>/broker/entra-oidc/endpoint`
     - **Client secret** generated.
     - API permissions `openid`, `profile`, and `email` (delegated).  Optionally `offline_access` for refresh tokens.
     - **Group claims** configured if you want to map AD groups into Keycloak roles (Enterprise app → Token configuration → Add groups claim).

4. kubectl access to your cluster.

## Usage

1. **Customize secrets**:

   Edit `01-secret-admin.yaml` and replace:
   - `KC_URL` with your Keycloak URL (e.g. `https://hmkeycloak.hypermute.cloud`).
   - `KC_REALM` with the realm you want to configure (e.g. `lab`).
   - `KC_ADMIN_USER` and `KC_ADMIN_PASSWORD` with your admin credentials.

   Edit `02-secret-entra.yaml` and replace:
   - `ENRA_TENANT_ID` with your Azure tenant ID.
   - `ENRA_CLIENT_ID` with the client ID of your Entra app registration.
   - `ENRA_CLIENT_SECRET` with its client secret.

2. **Apply the manifests**:

   ```bash
   chmod +x build/install/14-link-entra.sh
   ./build/install/14-link-entra.sh <kube-context>
   ```

   Omit `<kube-context>` to use the current context, or specify your cluster context (e.g. `copine-k801`).

3. **Verify**:

   Follow the Job logs to ensure successful creation:

   ```bash
   kubectl -n keycloak logs job/keycloak-entra-link
   ```

   In the Keycloak admin console, navigate to **Identity Providers** in your realm. You should see a new provider called `entra-oidc`.  Users can now authenticate through Entra ID.

4. **Map groups**:

   The script creates a groups‑to‑roles mapper that interprets the `groups` claim from Entra and automatically creates corresponding Keycloak roles.  Ensure your Entra app’s token configuration issues the `groups` claim.  You may then map those roles to permissions in downstream clients.

5. **Re‑apply safely**:

   The script checks whether the identity provider and mappers exist and skips creation if they do.  Re‑running the job is idempotent.

## Notes

- The Job runs using the `quay.io/keycloak/keycloak:latest` image so it has `kcadm.sh`.  To ensure compatibility with your deployed Keycloak version, you can override the image tag in `04-job-keycloak-entra.yaml`.
- This bundle does not change any clients or roles in Keycloak; it simply registers Entra as an identity provider and configures basic mappers.
- For advanced mappings (e.g. linking a custom claim to a Keycloak user attribute), you can extend the `entra-link.sh` script accordingly.
