# StatefulSet — Stable Identities & Storage

StatefulSets provide stable network IDs and stable storage for stateful applications (databases, message queues).

Key points:
- Each pod gets a stable identity: `<statefulset-name>-<ordinal>`.
- Use a headless Service (`clusterIP: None`) to enable stable DNS records.
- Use `volumeClaimTemplates` to provision per-pod PVCs.
- `updateStrategy` supports `RollingUpdate` and `OnDelete`.

Example headless Service (required):
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  clusterIP: None
  selector:
    app: web
```

Example StatefulSet:
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "web"
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
      storageClassName: fast
```

Operational notes:
- Scale carefully: pod ordinals and storage attachments matter; prefer graceful scale-down.
- Use `podManagementPolicy: Parallel` for faster rollout where appropriate.
- For shared storage across replicas, use RWX-capable storage (NFS, CSI supporting RWX).

Commands:
```bash
kubectl get statefulsets
kubectl describe statefulset web
kubectl get pvc -l app=web
```
