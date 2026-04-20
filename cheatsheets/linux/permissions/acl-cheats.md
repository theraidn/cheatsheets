# Permissions & ACLs — Quick Reference

- Standard permissions examples:
```bash
chmod 0644 file        # owner rw, group/other r
chown user:group file   # change ownership
```

- View and modify ACLs:
```bash
getfacl file
setfacl -m u:deploy:rwx /path/to/dir
```

Security note: avoid granting broad write access on directories served by network services.
