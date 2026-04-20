# StatefulSet — Backup & Restore Patterns

StatefulSets require careful handling for storage and identity. Typical backup/restore patterns:

1. Snapshot-based restore (recommended where CSI supports snapshots)
   - Scale the StatefulSet to 0 replicas: `kubectl scale sts/myapp --replicas=0 -n myns`.
   - Create VolumeSnapshots of each PVC (or rely on scheduled snapshots).
   - Create new PVCs from each VolumeSnapshot using the same claim names expected by the StatefulSet (or edit StatefulSet to point to restored PVCs).
   - Scale the StatefulSet up.

2. Application-aware backup
   - Use application-native tools (e.g., `pg_dump`, `mysqldump`) or operators that provide snapshot/export functionality.
   - Store dumps in object storage and restore into a fresh StatefulSet.

3. Full-cluster backup
   - Use Velero (with CSI snapshotter plugin) to snapshot PVs and backup resource manifests.

Example: restore PVC from snapshot (per ordinal):
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: www-web-0   # match naming expected by StatefulSet
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: fast
  resources:
    requests:
      storage: 10Gi
  dataSource:
    name: mypvc-snapshot-0
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
```

Operational tips
- Keep `podManagementPolicy` and `updateStrategy` in mind when performing restores. `OnDelete` gives manual control.
- Test your restore procedure in a staging cluster — practice is essential.
