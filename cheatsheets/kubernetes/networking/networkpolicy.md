# NetworkPolicy — Patterns, Examples, and Troubleshooting

Kubernetes `NetworkPolicy` controls L3/L4 traffic to and from Pods. Policies are namespaced and enforced by the cluster CNI (Calico, Cilium, etc.). They are additive (allowed traffic is the union of matching rules) and only affect Pods selected by a policy's `podSelector`.

Key semantics

- Scope: NetworkPolicy is namespaced — a policy can only select pods in the same namespace as the policy.
- Selection: `podSelector` chooses which pods the policy applies to. An empty `podSelector: {}` selects all pods in the namespace.
- Isolation: If a Pod is not selected by any NetworkPolicy, it is not isolated (default allow). If a Pod is selected by at least one policy, traffic of the directions covered by that policy is restricted to the allowed rules.
- Directions: `ingress` controls inbound traffic to pods; `egress` controls outbound traffic from pods. Use `policyTypes` to make intent explicit (`Ingress`, `Egress`).
- Rule matching: `from` / `to` entries may contain `podSelector`, `namespaceSelector`, and/or `ipBlock`. If both `podSelector` and `namespaceSelector` are present in the same entry, the pod selector is evaluated in the selected namespaces.

Best practices

- Start with a default-deny baseline and open only required ports and sources:
  - Create a `default-deny` `Ingress` policy first, then add explicit allow rules.
  - When enabling egress restrictions, ensure DNS and other infra services are allowed.
- Label namespaces you want to select from (e.g., `kubectl label namespace frontend team=frontend`) and use `namespaceSelector` rather than relying on namespace names in policies.
- Always set `policyTypes` explicitly to avoid surprises.
- Test incrementally: roll out policies to a small set of pods/namespaces before cluster-wide application.
- Remember behavior depends on your CNI: Calico and Cilium provide additional features and debugging tools.

Examples

1) Default deny (ingress + egress)

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: app
spec:
  podSelector: {}             # selects all pods in namespace `app`
  policyTypes:
  - Ingress
  - Egress
```

2) Allow HTTP (80) ingress to pods labeled `app=web` from pods in namespace(s) labeled `team=frontend`

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
    ports:
    - protocol: TCP
      port: 80
  policyTypes:
  - Ingress
```

3) Allow pods to use cluster DNS (UDP 53) — label `kube-system` or adapt to your DNS deployment

Note: many clusters don't label `kube-system` for selection by default; label it or label the DNS deployment namespace for predictable selection.

```yaml
# ensure the kube-system namespace has a selector label (example):
# kubectl label namespace kube-system network-policy-managed=true

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
  namespace: app
spec:
  podSelector: {}
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          network-policy-managed: "true"
      podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
    - protocol: UDP
      port: 53
  policyTypes:
  - Egress
```

4) Allow egress to an external CIDR but exclude a subnetwork

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-egress-corp
  namespace: app
spec:
  podSelector:
    matchLabels:
      app: web
  egress:
  - to:
    - ipBlock:
        cidr: 203.0.113.0/24
        except:
        - 203.0.113.128/25
    ports:
    - protocol: TCP
      port: 443
  policyTypes:
  - Egress
```

5) Allow traffic only to specific pods in another namespace (namespaceSelector + podSelector)

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-to-specific-pods
  namespace: app
spec:
  podSelector:
    matchLabels:
      app: api
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          env: frontend
      podSelector:
        matchLabels:
          role: gateway
  policyTypes:
  - Ingress
```

Notes on semantics and gotchas

- Union semantics: multiple NetworkPolicies applying to the same Pod combine; traffic is allowed if any matching rule permits it.
- Empty `podSelector` (`{}`) selects all pods in the namespace — useful to implement namespace-wide baselines.
- `ipBlock` rules cannot be combined with `podSelector`/`namespaceSelector` in the same `from`/`to` entry (they are separate items in the list), and `ipBlock` matches CIDRs only.
- `policyTypes` should be set to `Ingress` or `Egress` (or both) to make intent explicit; when omitted, Kubernetes infers direction based on which rules are present — explicit is less error-prone.
- NetworkPolicy does not control traffic to/from nodes, hostNetwork Pods, or external load-balancer health checks in a consistent way; behavior depends on CNI implementation and node-level routing/NAT.

Testing & Debugging

- Basic inspection:
```bash
kubectl get networkpolicy -n app
kubectl describe networkpolicy allow-frontend-to-web -n app
kubectl get pods -n app --show-labels
```

- Connectivity tests (ad-hoc pod):
```bash
# quick HTTP test
kubectl run --rm -it --restart=Never --image=curlimages/curl curl-test -- sh -c "curl -sS http://web-svc:80/health"

# raw TCP/UDP probe (netcat/netshoot images are useful)
kubectl run --rm -it --restart=Never --image=nicolaka/netshoot netshoot -- bash
# inside netshoot: nc -vz web-svc 80
```

- CNI-specific tools:
  - Calico: `calicoctl` (policy inspection), `calicoctl get policy -o yaml`, `calicoctl node status`.
  - Cilium: `cilium policy get`, `cilium monitor`, `cilium status` (eBPF flows and logs).

- Common debug checklist:
  - Confirm the Pod labels match `podSelector` (`kubectl get pods -L app -n app`).
  - Confirm namespace labels for `namespaceSelector` are present.
  - Describe the policy to verify generated rules: `kubectl describe networkpolicy <name>`.
  - Check whether the CNI reports denied packets (Cilium/Calico logs/CLIs are helpful).
  - When in doubt, test connectivity from a pod running an interactive debug image and observe packet drops.

Rollout strategies

- Add policies incrementally:
  1. Apply a `default-deny` `Ingress` policy to namespace(s).
  2. Add specific `ingress` allow rules for critical services.
  3. Add `egress` controls last, after ensuring DNS and control-plane dependencies are allowed.
- Use a `canary` namespace or label a small set of pods to validate policy rules before broad rollout.

Advanced & CNI-specific features

- Calico and Cilium extend NetworkPolicy semantics (selectors by service account, labels, HTTP-level L7 policies, global policies, host endpoints). When you require richer semantics (L7, traceable flows, observability), prefer these CNIs and consult their docs.
- For high-performance clusters, eBPF-based CNIs (Cilium) reduce overhead and provide better observability for policy enforcement.

References & further reading

- Kubernetes NetworkPolicy docs: https://kubernetes.io/docs/concepts/services-networking/network-policies/
- Calico docs: https://docs.projectcalico.org
- Cilium docs: https://cilium.io/docs

Use the examples in this directory to adapt the policies to your namespace layout and CNI capabilities. Start with a conservative default-deny and open only what's necessary.
