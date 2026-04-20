# Linux Kernel — Useful Commands

- Show kernel version:
```bash
uname -sr
```

- List loaded modules:
```bash
lsmod
```

- Show module info:
```bash
modinfo <module>
```

- Inspect recent kernel messages (errors/warnings):
```bash
dmesg --level=err,warn | tail -n 200
```

Tip: For reproducible kernel module installs prefer DKMS or distribution packages.
