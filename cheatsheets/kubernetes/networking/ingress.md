# Ingress — Controllers, TLS, and Examples

An `Ingress` defines HTTP(S) routing to Services. An Ingress resource requires an Ingress Controller (e.g., `nginx-ingress`, `contour`, `traefik`).

Important: use `networking.k8s.io/v1` and prefer `ingressClassName` over annotations where possible.

Example (basic host + TLS):
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
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

Controller notes:
- NGINX: use annotations like `nginx.ingress.kubernetes.io/rewrite-target` for path rewrites.
- Contour/Envoy and Traefik use different annotations and CRDs; consult controller docs.

TLS & certs:
- Use `cert-manager` to provision `Secret` TLS certificates automatically (`ClusterIssuer`).

Commands:
```bash
kubectl get ingress -A
kubectl describe ingress web-ingress -n myns
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```

Alternative: The Modern Approach
- Consider the Gateway API (more expressive) or Service Mesh Gateways for advanced traffic control.
