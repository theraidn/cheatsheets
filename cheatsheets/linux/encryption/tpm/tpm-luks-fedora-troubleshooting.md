# TPM + LUKS — Troubleshooting & PCR Checks (systemd-cryptenroll)

Diagnostic and recovery steps for TPM-sealed LUKS on Fedora using systemd-cryptenroll.

## Quick Checks

**Is TPM available?**
```bash
tpm2_getcap handles-persistent
# Should list persistent handles; if empty or errors, TPM may not be initialized.
```

**Are TPM bindings present?**
```bash
sudo systemd-cryptenroll --list-devices
# Should show your device with tpm2 slot listed.
```

**Are TPM PCRs in expected state?**
```bash
sudo tpm2_pcrread
# Note the values for PCR0, PCR7 (firmware, secure boot).
# If they change between boots, auto-unlock will fail (use fallback passphrase).
```

## Common Issues

### Issue 1: Boot prompts for passphrase (TPM unlock didn't work)

**Diagnosis:**
```bash
sudo journalctl -b | grep -i "cryptsetup\|tpm"
# Look for TPM and cryptsetup errors.
```

**Possible causes:**
- PCR values changed (e.g., BIOS update, kernel version change, SecureBoot toggle).
- TPM was cleared or lost state.
- Device not properly sealed to TPM.

**Recovery:**
```bash
# 1. Use fallback passphrase to boot.
# 2. Check PCR values:
tpm2_pcrread

# 3. Re-seal the key to the new PCR state:
sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/nvme0n1p2
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0,7 /dev/nvme0n1p2

# 4. Reboot and test.
```

### Issue 2: LUKS slot errors

**Diagnosis:**
```bash
sudo cryptsetup luksDump /dev/nvme0n1p2
# Shows all key slots and their state.

sudo systemd-cryptenroll --list-devices
# Shows systemd-cryptenroll TPM slots.
```

**Recovery:**
- Check available slots and verify TPM binding:
```bash
sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/nvme0n1p2
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0,7 /dev/nvme0n1p2
```

## PCR Monitoring

Track PCR changes to anticipate unlock failures:

```bash
#!/usr/bin/env bash
# Monitor PCR 0 and 7 before/after kernel updates

echo "Before:"
tpm2_pcrread 0 7

# (do system update or reboot)

echo "After:"
tpm2_pcrread 0 7
```

If PCRs differ, re-seal:
```bash
sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/nvme0n1p2
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0,7 /dev/nvme0n1p2
```

## Major OS/Kernel Update Breaks TPM Unlock

After a major Fedora or kernel update, PCR values often change, preventing automatic TPM unlock. The system will fall back to prompting for the passphrase, which is expected behavior.

**Recovery after major update:**

1. Boot with fallback passphrase (system should prompt for it).

2. After boot, re-seal the TPM key to match the new system state:
```bash
sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/nvme0n1p2
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0,7 /dev/nvme0n1p2
```

3. Verify the new PCR values and sealing:
```bash
tpm2_pcrread 0 7
sudo systemd-cryptenroll --list-devices
```

4. Reboot to test. The system should now auto-unlock using the updated TPM binding.

**Notes:**
- This is **normal** and expected after kernel/firmware updates.
- Always keep a recovery medium available (USB or live ISO) in case re-sealing fails.
- Consider automating re-sealing via systemd service or cron after system updates if you want zero-prompt boots.

## Fallback: Remove TPM binding

If issues persist, remove TPM binding and return to manual passphrase entry:

```bash
sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/nvme0n1p2
# Reboot; you'll be prompted for passphrase as before.
```

## Log Inspection

Check systemd and cryptsetup logs:

```bash
# Boot logs
sudo journalctl -b | grep -i "cryptsetup\|tpm"

# Persistent logs
sudo journalctl --no-pager | grep -i "tpm\|cryptsetup" | tail -50
```
