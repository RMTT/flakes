# Karakeep Service

Karakeep is deployed using Helm. This chart contains:
- `web`: The main Next.js application.
- `chrome`: Headless chrome used for extracting web pages.
- `meilisearch`: Search engine.

## Configuration

Secrets are managed via SOPS. To deploy this, ensure your `values.yaml` (or SOPS encrypted values file) overrides the default secrets.

```yaml
karakeep:
  host: "karakeep.local"
  nextAuthUrl: "https://karakeep.local"
  secrets:
    nextAuthSecret: "..."
    meiliMasterKey: "..."
    nextPublicSecret: "..."
    openaiApiKey: "..."
```

```
