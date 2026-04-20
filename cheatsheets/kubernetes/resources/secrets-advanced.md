# Secrets — SealedSecrets, SOPS, and Encryption

Avoid storing raw secrets in git. Common patterns:

- **SealedSecrets (Bitnami kubeseal)**: encrypt a Secret into a SealedSecret that can be safely stored in git.

Example: create sealed secret
```bash
kubectl create secret generic mysecret --from-literal=password=topsecret --dry-run=client -o yaml \
  | kubeseal --format yaml > sealedsecret.yaml
```

- **SOPS**: encrypt YAML files with KMS (AWS KMS, GCP KMS, Azure KeyVault); keep encrypted files in git and decrypt at CI time.

Kubernetes-native
- Use `stringData` when creating Secrets from manifests to avoid manual base64 encoding:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
stringData:
  password: topsecret
```

Encryption at rest
- Enable API server `EncryptionConfiguration` to encrypt Secrets in etcd at rest; consult Kubernetes doc for setup.

Access control
- Restrict secrets access via RBAC (grant service accounts the minimal `get`/`list` access they need).
