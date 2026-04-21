## SSH Key creation

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

Command for sending public key to remote system:

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub username@remote_host
```

## SSH config config example:

```
Host system_name1
        HostName 10.0.0.1
        User root
        IdentityFile ~/.ssh/id_rsa
```
