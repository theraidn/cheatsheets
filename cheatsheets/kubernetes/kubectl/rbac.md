# RBAC — Roles, ClusterRoles, and Bindings

RBAC controls access to the Kubernetes API. Use least privilege: grant only the verbs/resources required.

Role (namespace-scoped) example:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: myns
  name: pod-reader
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get","watch","list"]
```

RoleBinding example:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: myns
subjects:
  - kind: User
    name: jane
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

ClusterRole/ClusterRoleBinding give cluster-wide permissions; use with caution.

Useful commands:
```bash
kubectl get roles,rolebindings -n myns
kubectl get clusterrole,clusterrolebinding
kubectl auth can-i create pods --as system:serviceaccount:myns:my-sa
kubectl describe rolebinding read-pods -n myns
```

Best practices:
- Avoid `cluster-admin` for service accounts used by CI; prefer fine-grained ClusterRole.
- Use tools like `rbac-lookup` and `kube-score` to audit permissions.
