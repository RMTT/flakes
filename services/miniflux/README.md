# Miniflux Service

Miniflux is deployed using a custom Helm chart. Reference the [Official Miniflux Documentation](https://miniflux.app/docs/).

This chart contains:

- `miniflux`: The main feed reader application container.
- `miniflux-db`: A PostgreSQL database cluster managed by the CloudNativePG (CNPG) operator.
- `miniflux-secrets`: A Secret containing configuration secrets such as the admin username and password.

## Installation and Upgrades

To install or upgrade this service:

```bash
# From the services/miniflux directory
../../.bin/service-upgrade
```

## Configuration

Secrets are managed via SOPS. Before deploying, replace the placeholder admin credentials in `values.yaml` and encrypt the file using SOPS:

```bash
sops -e -i values.yaml
```

### Key Values

| Value | Description | Default |
|-------|-------------|---------|
| `nodeSelector` | Kubernetes node selection constraint | `kubernetes.io/hostname: kube-runner` |
| `database.size` | PVC storage size for the Postgres database | `5Gi` |
| `secrets.adminUsername` | Initial admin username | `admin` |
| `secrets.adminPassword` | Initial admin password | `some-random-password-here` |
| `secrets.oidcClientSecret` | (Optional) OIDC Client Secret | `""` |

### OpenID Connect (OIDC) Configuration

Miniflux supports OIDC Single Sign-On (SSO) using Authelia. To enable it:

1. Add your OIDC Client Secret in the secrets section in `values.yaml` (which should be encrypted with SOPS):
   ```yaml
   secrets:
     oidcClientSecret: "your-client-secret"
   ```

2. Add Miniflux to the `oidcClients` list in Authelia (`services/authelia/values.yaml`):
   ```yaml
   oidcClients:
     - client_id: "miniflux"
       client_name: "Miniflux"
       client_secret: "your-client-secret-digest" # The digest/hash of your client secret
       public: false
       authorization_policy: "two_factor"
       require_pkce: false
       pkce_challenge_method: ""
       redirect_uris:
         - "https://miniflux.rmtt.tech/oauth2/oidc/callback"
       scopes:
         - "openid"
         - "profile"
         - "email"
       response_types:
         - "code"
       grant_types:
         - "authorization_code"
       access_token_signed_response_alg: "none"
       userinfo_signed_response_alg: "none"
       token_endpoint_auth_method: "client_secret_basic"
   ```

