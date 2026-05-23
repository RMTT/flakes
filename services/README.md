## Services
> Based on Kubernetes now

The order to apply:

```
operators     
kube-system     |--> postgresql --> other apps ....
```

### Architecture

+ network infrastructure: godel(based on wireguard). All nodes that be used to deploy services should be inserted into godel
+ runtime: k3s
+ deploy tools: helm + helm-secrets + kustomization(for crds)

All services under this folder should keep consistency:
1. the first hierarchy of diectories shoule be the namespace name
2. the release name should be the folder name if there are no deeper hierarchy. For example, `services/operators` should deploy via `helm upgrade --install operators . -n operators --create-namespace`
3. otherwise, the name of second hierarchy should be the release name.

### Notes

#### About NodePort service

For satety, the NodePort service only accept node-ip as destination.
