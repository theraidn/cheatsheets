# Pre-commit Hooks — Example Configuration

Example `.pre-commit-config.yaml` to enforce basic hygiene:
```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml

  - repo: https://github.com/psf/black
    rev: 24.7b0
    hooks:
      - id: black
```

Install and enable:
```bash
pip install pre-commit
pre-commit install
```
