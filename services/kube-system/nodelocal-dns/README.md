## NodeLocal DNSCache

Runs a DNS caching agent on each cluster node as a DaemonSet, reducing DNS lookup latency from ~5ms to ~0.2ms by avoiding iptables DNAT and conntrack for DNS queries.

### Architecture

```
Pod → NodeLocal DaemonSet (on same node) → CoreDNS (cache miss only)
     └─ Local (0.2ms)                    └─ Network (5ms, rare)
```

### Deploy

```bash
helm upgrade --install nodelocal-dns . -n kube-system
```

### Configuration

| Value | Default | Description |
|-------|---------|-------------|
| `localDNS` | `169.254.20.10` | Local listen IP for the DNS cache |
| `clusterDNS` | `10.43.0.10` | kube-dns service ClusterIP |
| `clusterDomain` | `cluster.local` | Kubernetes cluster domain |
| `cache.successTTL` | `30` | TTL in seconds for successful DNS responses |
| `cache.denialTTL` | `5` | TTL in seconds for NXDOMAIN responses |

### Notes

- k3s runs kube-proxy in **iptables mode**, so NodeLocal binds to both the local DNS IP and the kube-dns service IP. Existing pods use the cache automatically without kubelet changes.
- Metrics are exposed on port `9253` and scraped by Prometheus via pod annotations.
- The `kube-dns-upstream` Service provides a stable endpoint for the cache to forward to CoreDNS.
