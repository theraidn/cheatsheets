# CNI Deep Dive — Calico, Cilium, and Best Practices

This note expands on CNIs, policies, and practical debug/checks.

eBPF vs iptables
- eBPF (used by Cilium) runs in-kernel with lower overhead and better observability. It reduces iptables churn and improves performance for high-throughput clusters.
- iptables-based CNIs (or userspace helpers) are widely supported but can suffer from large rule counts on busy clusters.

Calico highlights
- Policy: supports Kubernetes NetworkPolicy plus Calico GlobalNetworkPolicy/NetworkPolicy for advanced selectors and host endpoints.
- Routing: can run BGP to advertise pod CIDRs.
- Useful checks:
```bash
kubectl get daemonset calico-node -n kube-system
kubectl logs -n kube-system ds/calico-node
# calicoctl commands (requires calicoctl configured)
calicoctl node status
calicoctl get bgppeers -o wide
```

Cilium highlights
- Uses eBPF for datapath, provides rich observability (`cilium monitor`), and supports L7 policies via Envoy/Policys.
- Useful checks:
```bash
kubectl -n kube-system get pods -l k8s-app=cilium
kubectl -n kube-system logs ds/cilium
cilium status
cilium monitor  # live flow/connection monitor (requires cilium cli)
```

NetworkPolicy patterns
- Default-deny baseline (recommended):
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: app
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

- Allow HTTP from frontend namespace (namespaceSelector requires namespace labels):
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
    - namespaceSelector:
        matchLabels:
          team: frontend
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 80
  policyTypes:
  - Ingress
```

Debugging checklist
- Check CNI pods/daemonsets and their logs in `kube-system`.
- Inspect node routing (`ip route`) and interfaces for host-level issues.
- For iptables CNIs: inspect `iptables-save` on nodes; for eBPF CNIs use `cilium monitor` or tools the CNI provides.
- Use a default-deny policy then open explicit rules to iterate safely.

Notes
- NetworkPolicy enforcement depends on the CNI implementation; behavior may vary across CNIs. Label namespaces if you want to select by namespace label.
