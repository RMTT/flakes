## Services
> Based on Kubernetes now

The order to apply:

```
operators     
kube-system     |--> postgresql --> other apps ....
cert-issuer
```

### Architecture

+ network infrastructure: godel(based on wireguard). All nodes that be used to deploy services should be inserted into godel
+ runtime: k3s

All services under this folder should keep consistency:
1. the first hierarchy of diectories shoule be the namespace name
2. the release name should be the folder name if there are no deeper hierarchy. For example, `services/operators` should deploy via `helm upgrade --install operators . -n operators --create-namespace`
3. otherwise, the name of second hierarchy should be the release name.

### Database for apps

Apps needing a database to work should create postgresql instance under `services/postgresql`

### Notes

#### How to scale up Traefik?

In default, k3s only install one traefik instance per cluster and one servicelb(forward traffic to traefik via netfilter) per node, to scale up traefik instance:

1. configure `deployment.prelicas` in HelmChartConfig of Traefik, which located at `services/k3s/traefik-custom-config.yaml`

2. via `kubectl scale --replicas x deployment -n kube-system traefik`

#### How to scale up CoreDNS

via `kubectl scale --replicas x deployment -n kube-system coredns`
