## Network policy example

See the dedicated guide: [networkpolicy.md](networkpolicy.md) for patterns, semantics and debugging.

### default policy (ingress allow; egress restricted)

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ns-default-policy
  namespace: ns
spec:
  podSelector: {} 
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - {} 
  egress:
    # DNS
    - ports:
        - protocol: UDP
          port: 53
    # HTTP
    - ports:
        - protocol: TCP
          port: 80
    # HTTPS
    - ports:
        - protocol: TCP
          port: 443
