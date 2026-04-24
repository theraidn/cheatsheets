# cert-manager — Advanced Configurations and Patterns

## Certificate Rotation & Renewal

cert-manager automatically renews certificates before expiry (default: 30 days before).

### Custom renewal window

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: example-cert
spec:
  secretName: example-tls
  duration: 2160h  # 90 days
  renewBefore: 720h  # renew 30 days before expiry
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
  - example.com
```

### Check renewal status

```bash
kubectl describe certificate example-cert
kubectl get certificaterequest -n default --sort-by=.metadata.creationTimestamp
kubectl logs -n cert-manager deploy/cert-manager | grep example-cert
```

## Multiple Certificate Formats

Use `Certificate.spec.formats` to emit multiple certificate formats (PEM, DER, CombinedPEM):

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: example-cert
spec:
  secretName: example-tls
  formats:
  - pem
  - der
  - combined-pem
  issuerRef:
    name: ca-issuer
    kind: ClusterIssuer
  commonName: example.com
  dnsNames:
  - example.com
```

The resulting Secret contains: `tls.crt`, `tls.key`, `tls.der`, `tls.combined.pem`, etc.

## Wildcards with DNS-01

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: wildcard-cert
spec:
  secretName: wildcard-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
  - example.com
  - "*.example.com"  # wildcard domain
```

Requires DNS-01 solver configured for `*.example.com`:

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
      name: letsencrypt-prod
    solvers:
    - dns01:
        route53:
          region: us-east-1
          accessKeyID: AKIA...
          secretAccessKey:
            name: route53-credentials
            key: secret-key
      selector:
        dnsNames:
        - "*.example.com"
```

## Email Notifications on Certificate Expiry

Use external-secrets + webhook or integrate with cert-manager's webhook:

```bash
# Install webhook for notifications
helm install cert-manager-webhook-slack \
  --repo https://charts.verylongdomainname.com webhook \
  --namespace cert-manager
```

Or monitor via Prometheus:

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    # ... ACME config ...
    # Add monitoring via Prometheus alerts on Certificate readiness
```

## Cert-Manager Webhook Customization

Custom webhooks can validate Certificate specs before admission:

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: cert-manager-webhook
webhooks:
- name: webhook.cert-manager.io
  clientConfig:
    service:
      name: cert-manager-webhook
      namespace: cert-manager
      path: "/validate"
  rules:
  - operations: ["CREATE", "UPDATE"]
    apiGroups: ["cert-manager.io"]
    apiVersions: ["v1"]
    resources: ["certificates"]
```

## Performance Tuning

Monitor cert-manager reconciliation:

```bash
# Check metrics
kubectl port-forward -n cert-manager svc/cert-manager 9402:9402
# Visit http://localhost:9402/metrics

# Key metrics:
# - certmanager_certificate_expiration_timestamp_seconds
# - certmanager_certificate_renewal_errors_total
# - certmanager_orders_total
# - certmanager_challenges_total
```

Adjust controller args for high-scale deployments:

```yaml
helm install cert-manager jetstack/cert-manager \
  --set global.leaderElection.enabled=true \
  --set acme.http01.solvers[0].ingress.class=nginx \
  # Increase workers for high certificate volume
  --set args[0]="--concurrent-workers=20"
```

## Integration with External Secrets

Store ACME credentials in external secret manager:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-store
  namespace: cert-manager
spec:
  provider:
    vault:
      server: https://vault.example.com:8200
      path: secret
      auth:
        kubernetes:
          mountPath: auth/kubernetes
          role: cert-manager

---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: cloudflare-token
  namespace: cert-manager
spec:
  secretStoreRef:
    name: vault-store
    kind: SecretStore
  target:
    name: cloudflare-api-token
    template:
      engineVersion: v2
  data:
  - secretKey: token
    remoteRef:
      key: cloudflare
      property: api_token
```

## Debugging ACME Challenges

```bash
# View challenge status
kubectl get challenges -A
kubectl describe challenge <challenge-name> -n <namespace>
kubectl logs -n cert-manager deploy/cert-manager | grep <challenge-name>

# Check ACME order
kubectl get orders -A
kubectl describe order <order-name> -n <namespace>

# Verify DNS propagation (for DNS-01)
dig TXT _acme-challenge.example.com
nslookup -type=TXT _acme-challenge.example.com

# HTTP-01 challenge logs
kubectl logs -n <namespace> <ingress-pod>
```
