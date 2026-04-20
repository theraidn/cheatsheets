# systemd — Unit File & Commands

Common `systemctl` operations:
```bash
systemctl status myservice
systemctl enable --now myservice
systemctl daemon-reload
```

Minimal unit file example:
```
[Unit]
Description=Example service

[Service]
Type=simple
ExecStart=/usr/local/bin/example
Restart=on-failure

[Install]
WantedBy=multi-user.target
```
