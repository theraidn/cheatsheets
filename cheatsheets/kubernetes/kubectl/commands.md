# kubectl — Common Commands & Safe Usage

Quick tips:
- Prefer declarative manifests (`kubectl apply -f`) over imperative commands.
- Use contexts and namespaces to avoid accidental changes: `kubectl config use-context <ctx>`.
- Preview changes with `--dry-run=client` (or `--server-side --dry-run=server` on supported clusters) and `kubectl diff`.

Common commands:
```bash
# Cluster / context
kubectl config get-contexts
kubectl config set-context --current --namespace=my-namespace

# Inspect resources
kubectl get pods -A
kubectl describe pod mypod -n myns
kubectl get svc mysvc -o wide

# Logs & exec
kubectl logs -f deploy/myapp -n myns
kubectl exec -it pod/mypod -n myns -- /bin/sh

# Apply / delete safely
kubectl apply -f ./manifests --server-side --validate
kubectl delete -f ./manifests --dry-run=client

# Rolling updates
kubectl rollout status deploy/myapp -n myns
kubectl rollout restart deploy/myapp -n myns

# Debugging helpers
kubectl port-forward svc/mysvc 8080:80 -n myns
kubectl top pod mypod -n myns    # requires metrics-server
kubectl wait --for=condition=available deploy/myapp --timeout=120s -n myns
```

Best practices:
- Use `kubectl apply --server-side` where supported for stronger merge semantics.
- Avoid `kubectl exec`/`kubectl delete` in automation; prefer CI to apply manifests.
- Use `kubectl diff -f` in CI to preview changes before applying.

Alternative: The Modern Approach
- Use GitOps (ArgoCD / Flux) for declarative continuous delivery, and CI pipelines to run `kubectl diff` / `kubectl apply --server-side` with proper RBAC.
