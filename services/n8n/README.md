# n8n Service

n8n is deployed using a custom Helm chart. This chart contains:
- `n8n`: The main workflow automation application container.
- `n8n-db`: A PostgreSQL database cluster managed by the CloudNativePG (CNPG) operator.
- `n8n-pvc`: A PersistentVolumeClaim for local configuration and binary data.
- `n8n-secrets`: A Secret containing configuration secrets such as the encryption key.

## Installation and Upgrades

To install or upgrade this service:

```bash
# From the services/n8n directory
../../.bin/service-upgrade
```

## Configuration

Secrets are managed via SOPS. Before deploying, replace the placeholder `secrets.n8nEncryptionKey` with a secure random 32-character string in `values.yaml` and encrypt the file using SOPS:

```bash
sops -e -i values.yaml
```

### Key Values

| Value | Description | Default |
|-------|-------------|---------|
| `nodeSelector` | Kubernetes node selection constraint | `kubernetes.io/hostname: kube-runner` |
| `database.size` | PVC storage size for the Postgres database | `5Gi` |
| `persistence.size` | PVC storage size for n8n local data | `10Gi` |
| `secrets.n8nEncryptionKey` | 32-character random encryption key | `a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6` |

### OpenID Connect (OIDC) Single Sign-On (SSO)

OIDC SSO is available on n8n Business and Enterprise plans. To enable it:

1. In `values.yaml`, set `oidc.enabled` to `true`, and configure `clientId` and `discoveryEndpoint`.
2. Add your OIDC Client Secret in the secrets section:
   ```yaml
   secrets:
     oidcClientSecret: "your-client-secret"
   ```
3. Encrypt `values.yaml` using SOPS before deploying.

