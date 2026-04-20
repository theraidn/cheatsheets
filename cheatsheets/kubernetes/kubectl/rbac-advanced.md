# RBAC Advanced — ServiceAccount and Least Privilege Patterns

Granting a Role to a ServiceAccount (namespace-scoped):
```bash
kubectl create rolebinding sa-pod-reader \
  --role=pod-reader \
  --serviceaccount=myns:my-sa \
  -n myns
```

Example: narrow Role for reading a single Secret
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: secret-reader
  namespace: myns
rules:
  - apiGroups: [""]
    resources: ["secrets"]
    resourceNames: ["mysecret"]
    verbs: ["get"]
```

Verification
```bash
kubectl auth can-i get secrets/mysecret --as=system:serviceaccount:myns:my-sa -n myns
```

Best practices
- Prefer Role/RoleBinding over ClusterRoleBinding whenever possible.
- Use `resourceNames` to scope access to specific objects when applicable.
- Regularly audit RBAC with tools like `rbac-lookup` and `kube-bench`.
