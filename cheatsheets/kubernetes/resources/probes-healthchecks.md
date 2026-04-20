# Probes — Liveness, Readiness, and Startup

Kubernetes probes help the kubelet manage container lifecycle.

Types:
- `livenessProbe`: restarts a container if the probe fails.
- `readinessProbe`: controls whether a pod receives traffic from Services.
- `startupProbe`: used for slow-starting containers; if present, it disables liveness checks until successful.

Examples:
```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 15
  periodSeconds: 10
  timeoutSeconds: 2
  failureThreshold: 3

readinessProbe:
  tcpSocket:
    port: 5432
  initialDelaySeconds: 5
  periodSeconds: 10

startupProbe:
  exec:
    command: ["/bin/check-startup.sh"]
  failureThreshold: 30
  periodSeconds: 10
```

Troubleshooting:
- `kubectl describe pod <pod>` shows probe failures in events.
- `kubectl logs` for container logs around probe failures.
- Be conservative with `initialDelaySeconds` for cold starts.
