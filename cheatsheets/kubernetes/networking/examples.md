## Network policy example

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
