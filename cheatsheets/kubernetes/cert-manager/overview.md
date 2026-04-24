# cert-manager — Automatic Certificate Management

`cert-manager` is a Kubernetes controller that automates TLS/SSL certificate provisioning and renewal from ACME providers (Let's Encrypt, Vault, etc.).

## Key Concepts

**Issuer / ClusterIssuer**
- `Issuer`: namespace-scoped certificate authority
- `ClusterIssuer`: cluster-wide certificate authority
- Examples: ACME (Let's Encrypt), Vault, Self-signed, CA

**Certificate**
- Defines a desired certificate; cert-manager creates/renews it
- Stores the cert in a Kubernetes `Secret`

**ACME & Challenges**
- `http01`: validates domain ownership via HTTP endpoint (requires Ingress)
- `dns01`: validates via DNS TXT records (requires DNS provider integration)

## Installation

```bash
# Add Helm repo and install
helm repo add cert-manager https://charts.jetstack.io \
helm repo update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.20.2 \
  --set installCRDs=true
```

## Basic Setup: Let's Encrypt with ACME

```yaml
---
# ClusterIssuer for Let's Encrypt staging (for testing)
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: admin@example.com
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - http01:
        ingress:
          class: nginx
---
# ClusterIssuer for Let's Encrypt production
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
    - http01:
        ingress:
          class: nginx
```

## Create a Certificate

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: example-cert
  namespace: default
spec:
  secretName: example-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
  - example.com
  - www.example.com
```

## Use in Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - example.com
    secretName: example-tls
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web
            port:
              number: 80
```

## Common Commands

```bash
# Check cert-manager pods
kubectl get pods -n cert-manager
kubectl logs -n cert-manager deploy/cert-manager

# Inspect Certificate status
kubectl describe certificate example-cert -n default
kubectl get certificate -A

# Check CertificateRequest (intermediate resource)
kubectl describe certificaterequest -n default
kubectl get orders -n default
kubectl get challenges -n default

# Test with staging issuer first
kubectl get secret example-tls -n default -o yaml
```

## Quick Troubleshooting

- Certificate not ready? Check `kubectl describe certificate` for conditions and events
- ACME challenges failing? Verify DNS/HTTP solver config and check `Order` and `Challenge` objects
- Secret not created? Cert status shows "Unknown" or pending
