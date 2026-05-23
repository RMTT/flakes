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
