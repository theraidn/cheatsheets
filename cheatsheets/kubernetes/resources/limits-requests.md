# Resources — Requests, Limits & QoS

Requests vs Limits:
- `requests` reserve resources for scheduling; `limits` cap resource usage at runtime.

Example pod spec:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: example
spec:
  containers:
  - name: app
    image: nginx:stable
    resources:
      requests:
        cpu: "250m"
        memory: "128Mi"
      limits:
        cpu: "500m"
        memory: "256Mi"
```

QoS classes:
- **Guaranteed**: requests == limits for all containers.
- **Burstable**: requests < limits for at least one resource.
- **BestEffort**: no requests or limits set.

Commands:
```bash
kubectl top nodes
kubectl top pods -A    # requires metrics-server or equivalent
kubectl describe node <node> | egrep -A5 "Non-terminated Pods"
```

Autoscaling:
- Horizontal Pod Autoscaler (HPA) example (CPU-based):
```bash
kubectl autoscale deployment myapp --cpu-percent=60 --min=2 --max=10
```

Alternative: The Modern Approach
- Use Vertical Pod Autoscaler (VPA) for workload tuning, and setup cluster autoscaler for node scaling. Combine metrics (Prometheus Adapter) for custom HPA scaling.
