# ConfigMaps & Secrets — Usage Patterns

ConfigMaps store non-sensitive configuration data; Secrets store sensitive data and should be treated carefully.

Create ConfigMap from literal or file:
```bash
kubectl create configmap myconfig --from-literal=KEY=VALUE --from-file=app.conf
```

ConfigMap manifest example:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myconfig
data:
  config.yaml: |
    key: value
```

Consume ConfigMap as env or volume:
```yaml
envFrom:
  - configMapRef:
      name: myconfig

volumes:
  - name: config
    configMap:
      name: myconfig

volumeMounts:
  - mountPath: /etc/config
    name: config
```

Secrets (create safely):
```bash
kubectl create secret generic mysecret --from-literal=password=topsecret
```

Secret manifest (base64-encoded values):
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  password: cGFzc3dvcmQ=  # base64 for 'password'
```

Best practices:
- Avoid storing raw secrets in git; use SealedSecrets, SOPS or your cloud KMS.
- Restrict access via RBAC to service accounts that need secrets.
- Use `kubectl create secret` or secret-management tooling rather than hand-editing base64 values.
