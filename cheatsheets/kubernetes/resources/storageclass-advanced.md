# StorageClass & Snapshots — CSI VolumeSnapshot Workflow

Volume snapshots require the CSI snapshot sidecars and CRDs (`VolumeSnapshot`, `VolumeSnapshotClass`). Confirm your CSI driver supports snapshots.

VolumeSnapshotClass example (CSI driver-specific):
```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass
metadata:
  name: csi-aws-vsc
driver: ebs.csi.aws.com
deletionPolicy: Delete
```

Create a snapshot from an existing PVC:
```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: mypvc-snapshot
spec:
  volumeSnapshotClassName: csi-aws-vsc
  source:
    persistentVolumeClaimName: mypvc
```

Restore from a snapshot (create PVC that uses snapshot as dataSource):
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mypvc-restore
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: fast
  resources:
    requests:
      storage: 20Gi
  dataSource:
    name: mypvc-snapshot
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
```

Commands:
```bash
kubectl get volumesnapshotclass
kubectl get volumesnapshot -n myns
kubectl describe volumesnapshot mypvc-snapshot -n myns
kubectl get storageclass
kubectl describe storageclass fast
```

Notes:
- Snapshot support and restoration semantics depend on the CSI driver. Snapshotting while the workload is active may require application-level quiesce.
- For full application-consistent backups consider backup tools like Velero (with CSI snapshot support) or application-specific exports (e.g., DB dump).
