# Probes — Advanced Tuning, Patterns, and Debugging

Advanced recommendations for liveness/readiness/startup probes.

When to use which probe
- `startupProbe`: for slow-initializing apps; it disables liveness checks until the app is ready.
- `readinessProbe`: signal whether the pod should receive traffic — use to gate Service endpoints.
- `livenessProbe`: restarts unhealthy containers but avoid aggressive settings that cause flapping.

Strategy examples
- For a database with long start times, use `startupProbe` with a higher `failureThreshold` and `periodSeconds`.
- For HTTP apps, prefer `readinessProbe` on an internal health endpoint (e.g., `/health/ready`) and a simpler `livenessProbe`.

Common pitfalls
- `initialDelaySeconds` too small causes false positives during cold starts.
- HTTP probe returns 200 but service not fully initialized — use application-level readiness checks.

Debugging
- `kubectl describe pod <pod> -n <ns>` shows probe failures in Events.
- `kubectl logs <pod> -c <container> -n <ns>` for logs around failure times.

Example combined probes
```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 2
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 10

startupProbe:
  exec:
    command: ["/usr/local/bin/check-startup.sh"]
  failureThreshold: 60
  periodSeconds: 10
```
