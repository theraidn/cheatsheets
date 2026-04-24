# cert-manager — Issuer Types and Configuration

## Issuer vs ClusterIssuer

| Feature | Issuer | ClusterIssuer |
|---------|--------|---------------|
| Scope | Namespace | Entire cluster |
| Usage | Single namespace certs | Shared across namespaces |
| Typical use | Namespace-specific CAs | Shared ACME/Vault providers |

## Built-in Issuer Types

### Self-Signed

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned
spec:
  selfSigned: {}
```

### CA (from existing secret)

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ca-issuer
spec:
  ca:
    secretName: ca-key-pair  # Secret with tls.crt and tls.key
```

### ACME (Let's Encrypt / others)

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@example.com
    privateKeySecretRef:
      name: letsencrypt-prod-key
    solvers:
    # HTTP-01 solver (Ingress)
    - http01:
        ingress:
          class: nginx
    # DNS-01 solver (DNS provider)
    - dns01:
        cloudflare:
          email: admin@example.com
          apiTokenSecretRef:
            name: cloudflare-token
            key: api-token
      selector:
        dnsZones:
        - "example.com"
```

### Vault

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: vault-issuer
spec:
  vault:
    server: https://vault.example.com:8200
    path: pki/sign/example
    auth:
      kubernetes:
        role: cert-manager
        mountPath: /v1/auth/kubernetes
```

## ACME Solver Configuration

### HTTP-01 (for public domains)

Requires exposed HTTP endpoint on port 80 (e.g., via Ingress):

```yaml
solvers:
- http01:
    ingress:
      class: nginx
    # Optional: expose via specific Ingress class
```

### DNS-01 (for wildcard and private domains)

Requires DNS provider credentials:

```yaml
solvers:
- dns01:
    route53:
      region: us-east-1
      accessKeyID: AKIA...
      secretAccessKey:
        name: route53-credentials
        key: secret-key
- dns01:
    cloudflare:
      email: admin@example.com
      apiTokenSecretRef:
        name: cloudflare-api-token
        key: token
```

### Selector Constraints

Match specific domains/namespaces to solvers:

```yaml
solvers:
- http01:
    ingress:
      class: nginx
  selector:
    dnsNames:
    - "example.com"
    - "www.example.com"

- dns01:
    route53:
      region: us-east-1
      accessKeyID: AKIA...
      secretAccessKey:
        name: route53-credentials
        key: secret-key
  selector:
    dnsNames:
    - "*.private.example.com"
    namespaces:
    - apps
    - production
```

## Issuer Validation

```bash
# Check issuer status
kubectl get issuer -n default
kubectl describe issuer my-issuer -n default

# Check ClusterIssuer
kubectl get clusterissuer
kubectl describe clusterissuer letsencrypt-prod

# Common conditions
# - True: Issuer is ready
# - False: Configuration error or missing secret
```

## Best Practices

1. **Use ClusterIssuer** for shared ACME providers (Let's Encrypt)
2. **Use namespace Issuer** for isolated/custom CAs
3. **Test with staging** (`letsencrypt-staging`) first before production
4. **Store secrets securely**: Use external secrets operator or sealed secrets
5. **Monitor renewal**: Set up alerts for certificate expiry (check `cert status`)
6. **Backup**: ACME account keys stored in Secrets; include in cluster backups
