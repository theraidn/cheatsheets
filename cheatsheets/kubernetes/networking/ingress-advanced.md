# Ingress — Advanced Controller Notes & TLS (cert-manager)

IngressClass & Controller
- Define an `IngressClass` to bind Ingress resources to a controller:
```yaml
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: nginx
spec:
  controller: k8s.io/ingress-nginx
```

NGINX common annotations
- `nginx.ingress.kubernetes.io/rewrite-target: /`
- `nginx.ingress.kubernetes.io/proxy-body-size: 50m`
- `nginx.ingress.kubernetes.io/use-regex: "true"`

Cert-manager (ACME) — ClusterIssuer example
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
      - http01:
          ingress:
            class: nginx
```

Ingress TLS snippet (with cert-manager annotation)
```yaml
metadata:
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts:
    - example.com
    secretName: example-tls
```

Debugging & validation
- Check controller pods and logs:
```bash
kubectl get pods -n ingress-nginx
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
kubectl describe ingress web-ingress -n myns
```

Notes & gotchas
- `pathType` matters: `Prefix` is usually correct for most apps; `ImplementationSpecific` may differ between controllers.
- For client IP preservation, set Service `externalTrafficPolicy: Local` or configure the controller to pass X-Forwarded-For as needed.
- For greater flexibility, consider Gateway API (more expressive) when you need multi-cluster or advanced routing semantics.
