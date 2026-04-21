## fscrypt examples

### Installation

```bash
apt install libpam-fscrypt fscrypt
```

### SSH PAM Auth for supporting decryption by SSH login

Add following lines at the bottom of */etc/pam.d/sshd*:

```bash
auth    optional    pam_fscrypt.so
session optional    pam_fscrypt.so
```

### Example fscrypt.conf with Adiantum:
```bash
root@NAS:~# cat /etc/fscrypt.conf 
{
        "source":  "custom_passphrase",
        "hash_costs":  {
                "time":  "6",
                "memory":  "131072",
                "parallelism":  "4",
                "truncation_fixed":  true
        },
        "options":  {
                "padding":  "32",
                "contents":  "Adiantum",
                "filenames":  "Adiantum",
                "policy_version":  "2"
        },
        "use_fs_keyring_for_v1_policies":  false,
        "allow_cross_user_metadata":  false
}
```

### Setup encrypted directory

```bash
tune2fs -O encrypt /dev/sda2
fscrypt encrypt /opt/data_crypt
```