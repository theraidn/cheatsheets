# Helm — Best Practices & Commands

Quick rules:
- Use Helm 3 (no Tiller). Prefer `helm upgrade --install` for idempotency.
- Lint charts with `helm lint`, and render templates with `helm template` for CI checks.

Common commands:
```bash
helm repo add stable https://charts.helm.sh/stable
helm repo update
helm lint ./mychart
helm dependency update ./mychart

# Install or upgrade (safe flags)
helm upgrade --install myrelease ./mychart \
  --namespace myns --create-namespace \
  --values values.yaml --atomic --wait

# Render manifests locally
helm template myrelease ./mychart --values values.yaml
```

Tips:
- Use `--atomic` to roll back on failure and `--wait` to wait for Kubernetes resources to be ready.
- Keep sensitive values out of plain `values.yaml`; prefer sealed-secrets, SOPS, or your secret store.

Alternative: The Modern Approach
- For GitOps, combine Helm with tools like `helmfile`, `Flux`, or `ArgoCD`. Consider `Helmfile` for multi-chart orchestration or `Helm` charts converted to plain manifests for admission/validation steps.
