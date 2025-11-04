## Services
> Based on Kubernetes now

The order to apply:

```
operators     
            |--> postgresql --> other apps ....
cert-issuer
```

### Architecture

+ network infrastructure: godel(based on ipsec). All nodes that be used to deploy services should be inserted into godel
+ runtime: k3s

### Database for apps

Apps needing a database to work should create postgresql instance under `services/postgresql`

### TLS Cert for apps

TLS Certificates should be placed under `services/cert-manager/certs`. For example, the certificate name of domain a.xx.com should be a.xx.com, and it's tls secret name should be a.xx.com-tls. BTW, use `reflector` to copy secrets between namespace

### Notes

#### How to scale up Traefik?

In default, k3s only install one traefik instance per cluster and one servicelb(forward traffic to traefik via netfilter) per node, to scale up traefik instance:

1. configure `deployment.prelicas` in HelmChartConfig of Traefik, which located at `services/k3s/traefik-custom-config.yaml`

2. via `kubectl scale --replicas x deployment -n kube-system traefik`

#### How to scale up CoreDNS

via `kubectl scale --replicas x deployment -n kube-system coredns`
