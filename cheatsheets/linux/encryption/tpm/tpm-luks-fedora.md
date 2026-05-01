# TPM + LUKS — Auto-unlock System Partition on Boot (Fedora)

TPM2 can automatically unlock LUKS volumes during boot if the system state (PCR values) hasn't changed. This guide covers Fedora with systemd-cryptsetup and TPM2 tools.

## Prerequisites

- Fedora with a TPM 2.0 module (check: `tpm2-abrmd` or `tpm2-tools`).
- Root access and a backup of your system before enabling encryption.
- LUKS2 encrypted root partition (existing setup or fresh install with encryption enabled).

Check TPM availability:
```bash
tpm2_getcap handles-persistent | head
tpm2_pcrread
```

If `tpm2_pcrread` fails, install tools:
```bash
sudo dnf install tpm2-tools tpm2-abrmd
sudo systemctl enable tpm2-abrmd
sudo systemctl start tpm2-abrmd
```

## Setup TPM-sealed LUKS key

### Using systemd-cryptenroll

Use the native systemd tool for TPM binding:

1. Bind LUKS root partition to TPM PCRs (PCR0=firmware, PCR7=SecureBoot status):
```bash
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0,7 /dev/nvme0n1p2
```

2. Verify binding:
```bash
sudo systemd-cryptenroll --list-devices
```

3. Reboot and test. If PCRs match, the system will unlock automatically.

## Notes

- PCR sealing prevents boot if firmware/kernel changes (until you re-seal the key).
- TPM unsealing automates passphrase entry but is not a substitute for disk encryption; it still requires the TPM module to be physically secure.
- If unlock fails (PCR mismatch), you'll be prompted for a passphrase as fallback.
