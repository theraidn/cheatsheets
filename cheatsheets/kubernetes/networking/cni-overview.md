# Kubernetes Networking — CNI & NetworkPolicy Overview

CNI choices:
- **Calico**: NetworkPolicy enforcement, BGP support, scalable for datacenters.
- **Cilium**: eBPF-based dataplane, high-performance network and security policies.
- **Flannel**: Simple overlay for basic pod networking (less feature-rich).

Key concepts:
- Pod network (Pod CIDR) vs Service CIDR; CNIs provide pod-to-pod connectivity.
- `NetworkPolicy` controls L3/L4 traffic between pods; default is allow/deny depends on CNI.

Example: allow HTTP to `web` pods from `frontend` pods
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-web
  namespace: app
spec:
  podSelector:
    matchLabels:
      app: web
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 80
```

Debugging tips:
- Check CNI pods: `kubectl get pods -n kube-system -l k8s-app` (or provider-specific labels).
- Inspect node routes and `ip a`/`ip r` when troubleshooting host-level issues.

Alternative: The Modern Approach
- For advanced security and observability prefer `Cilium` (eBPF) and integrate with Service Mesh (Istio, Linkerd) only where necessary.
