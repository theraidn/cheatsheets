# StorageClass & Dynamic Provisioning

StorageClasses define how Kubernetes provisions PersistentVolumes dynamically.

Key fields:
- `provisioner`: CSI driver or in-tree provisioner (replace with your platform's driver).
- `reclaimPolicy`: `Delete` (remove backing storage) or `Retain` (keep PV after PVC deleted).
- `volumeBindingMode`: `Immediate` or `WaitForFirstConsumer` (prefer the latter for topology-aware scheduling).
- `allowVolumeExpansion`: `true`/`false` to permit resizing PVCs.

Example (replace `provisioner` with your CSI driver):
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast
provisioner: ebs.csi.aws.com   # example: replace with your CSI driver
parameters:
  type: gp2
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

PVC example using the StorageClass:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mypvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: fast
  resources:
    requests:
      storage: 20Gi
```

Useful commands:
```bash
kubectl get storageclass
kubectl describe storageclass fast
kubectl get pvc
kubectl describe pvc mypvc
```

Notes:
- Prefer `WaitForFirstConsumer` when using topology-aware CSI drivers (avoids provisioning in the wrong zone).
- Use `Retain` for PVs you must preserve after PVC deletion (manual cleanup required).
- Keep sensitive params out of public charts; treat storage credentials like secrets.
