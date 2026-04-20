# Helm — Advanced CI/CD Patterns and Secrets Handling

Helm in CI
- Lint and template charts in CI: `helm lint ./chart` and `helm template ./chart --values ci-values.yaml` to validate rendering.
- Use `helm test` to run chart-provided tests after install (if available).

Values schema and validation
- Add `values.schema.json` to chart to validate values provided during install/upgrade.

Handling secrets
- Avoid putting secrets in `values.yaml`. Use `helm secrets` (SOPS plugin) or render templates and inject secrets at deploy time from a secret store.

Tips
- Use `--atomic --wait` for safer upgrades.
- Use `helm dependency update` during packaging.
- Consider `helmfile` or GitOps tools (ArgoCD/Flux) for environment orchestration.
