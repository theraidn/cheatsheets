# kubectl — Advanced Tips, Kustomize, and JsonPath

Kustomize (built into kubectl):
```bash
kubectl apply -k ./overlays/prod
kubectl build kustomize ./base | kubectl apply -f -
```

jsonpath examples:
```bash
# List pod names
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' -n myns

# Get a pod's node
kubectl get pod mypod -o jsonpath='{.spec.nodeName}' -n myns
```

Useful commands & debugging
```bash
kubectl explain deployment.spec  # inspect API docs
kubectl get events -A --sort-by=.metadata.creationTimestamp
kubectl auth can-i delete pods --as system:serviceaccount:myns:my-sa
kubectl port-forward svc/mysvc 8080:80 -n myns
kubectl apply --server-side -f manifest.yaml
```

Tips for automation
- Use `--dry-run=client` or `--server-side --dry-run=server` to verify before applying.
- Prefer `kubectl diff -f` in CI to preview changes.
