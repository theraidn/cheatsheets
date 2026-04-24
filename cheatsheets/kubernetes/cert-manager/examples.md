# cert-manager — Real-World Examples

## Example 1: Simple HTTPS Ingress with Let's Encrypt

Setup: Single domain, automatic cert renewal

```yaml
---
# 1. ClusterIssuer for Let's Encrypt production
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ops@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx

---
# 2. Application Ingress with automatic cert
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  namespace: default
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - myapp.example.com
    secretName: myapp-tls
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp
            port:
              number: 8080
```

Deploy & verify:

```bash
kubectl apply -f ingress.yaml
# Wait for cert provisioning (1-2 minutes)
kubectl get certificate -w
kubectl describe certificate myapp-tls
kubectl get secret myapp-tls -o yaml
```

## Example 2: Wildcard Certificate with DNS-01 (Route53)

Setup: Wildcard + subdomain, AWS Route53 solver

```yaml
---
# 1. AWS credentials Secret
apiVersion: v1
kind: Secret
metadata:
  name: route53-credentials
  namespace: cert-manager
type: Opaque
stringData:
  access-key-id: AKIA...
  secret-access-key: "..."

---
# 2. ClusterIssuer with Route53 DNS-01
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod-dns
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ops@example.com
    privateKeySecretRef:
      name: letsencrypt-prod-dns
    solvers:
    - dns01:
        route53:
          region: us-east-1
          accessKeyID: AKIA...
          secretAccessKey:
            name: route53-credentials
            key: secret-access-key

---
# 3. Wildcard Certificate
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: wildcard-cert
  namespace: default
spec:
  secretName: wildcard-tls
  issuerRef:
    name: letsencrypt-prod-dns
    kind: ClusterIssuer
  dnsNames:
  - example.com
  - "*.example.com"
  - api.example.com

---
# 4. Use in Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - api.example.com
    - app.example.com
    secretName: wildcard-tls
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api
            port:
              number: 3000
  - host: app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app
            port:
              number: 80
```

## Example 3: Multi-Namespace with Namespace-Scoped Issuer

Setup: Each namespace has its own CA issuer

```yaml
---
# Deploy in each namespace
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: ca-issuer
  namespace: myapp
spec:
  ca:
    secretName: ca-key-pair

---
# Generate root CA (one-time)
# openssl genrsa -out ca.key 2048
# openssl req -x509 -new -nodes -key ca.key -days 3650 -out ca.crt
# kubectl create secret tls ca-key-pair --cert=ca.crt --key=ca.key -n myapp

---
# Certificate in namespace
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: myapp-cert
  namespace: myapp
spec:
  secretName: myapp-tls
  issuerRef:
    name: ca-issuer
    kind: Issuer
  commonName: myapp.myapp.svc.cluster.local
  dnsNames:
  - myapp.myapp.svc.cluster.local
  - myapp.myapp
  - myapp
```

## Example 4: Certificate with Custom Duration and Renewal

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: longlife-cert
spec:
  secretName: longlife-tls
  duration: 8760h  # 1 year
  renewBefore: 720h  # renew 30 days before expiry
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  commonName: api.example.com
  dnsNames:
  - api.example.com
  - "*.api.example.com"
```

## Example 5: Vault Issuer for Internal PKI

```yaml
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: vault-pki
spec:
  vault:
    server: https://vault.internal.example.com:8200
    path: pki/sign/kubernetes
    auth:
      kubernetes:
        role: cert-manager
        mountPath: /v1/auth/kubernetes

---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: internal-api-cert
spec:
  secretName: internal-api-tls
  issuerRef:
    name: vault-pki
    kind: ClusterIssuer
  commonName: internal-api.example.com
  dnsNames:
  - internal-api.example.com
  - internal-api.svc.cluster.local
  duration: 8760h
```

## Example 6: Monitoring & Alerting

Prometheus rule for expiring certificates:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: cert-manager-alerts
spec:
  groups:
  - name: cert-manager
    interval: 30s
    rules:
    - alert: CertificateExpiring
      expr: certmanager_certificate_expiration_timestamp_seconds - time() < 7 * 24 * 3600
      for: 1h
      annotations:
        summary: "Certificate {{ $labels.name }} expiring in 7 days"

    - alert: CertificateExpired
      expr: certmanager_certificate_expiration_timestamp_seconds - time() < 0
      for: 5m
      annotations:
        summary: "Certificate {{ $labels.name }} has expired"
```

## Troubleshooting Checklist

```bash
# 1. Verify cert-manager is running
kubectl get pods -n cert-manager

# 2. Check Certificate status
kubectl describe certificate myapp-tls -n default

# 3. Inspect Secret
kubectl get secret myapp-tls -o yaml

# 4. Review ACME challenges (if using ACME)
kubectl get challenges,orders -n default
kubectl describe challenge -n default

# 5. Check logs
kubectl logs -n cert-manager deploy/cert-manager -f

# 6. Verify issuer configuration
kubectl describe clusterissuer letsencrypt-prod

# 7. Test DNS resolution (for DNS-01)
kubectl run -it --rm debug --image=alpine --restart=Never -- sh
# nslookup _acme-challenge.example.com
```
