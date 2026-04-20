# Storage & Filesystems — Examples

- List block devices and filesystems:
```bash
lsblk -f
```

- Show UUIDs:
```bash
blkid
```

- Example `/etc/fstab` entry (use UUIDs):
```
UUID=<uuid>  /mnt/data  ext4  defaults,noatime  0 2
```

Tip: Use `smartctl` and `tune2fs` for disk health and tuning.
