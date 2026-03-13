# Installing the Entra ID Link Bundle

This document briefly summarizes the steps to deploy the Entra ID integration into your cluster:

1. **Populate secrets**: Fill in your Keycloak and Azure values in:
   - `build/keycloak-entra/01-secret-admin.yaml`
   - `build/keycloak-entra/02-secret-entra.yaml`

2. **Apply**: Run the install script from the root of this bundle (or adjust the path):

   ```bash
   chmod +x build/install/14-link-entra.sh
   ./build/install/14-link-entra.sh <context-name>
   ```

3. **Check**: Monitor the job logs and confirm the identity provider appears in the Keycloak admin console.

You can safely re-run the job if you update secrets or want to add more mappers; the script checks for existing resources before creating them.
