# Ansible — Vault & Secret Management

Ansible Vault provides lightweight file encryption for secrets stored in playbooks, roles, and inventory. For larger-scale secret management, integrate Ansible with external secret stores or use Vault (HashiCorp) / cloud secret managers.

## Basic Vault Commands

```bash
# Encrypt a file
ansible-vault encrypt group_vars/all/vault.yml

# Decrypt a file
ansible-vault decrypt group_vars/all/vault.yml

# Edit in-place
ansible-vault edit group_vars/all/vault.yml

# View content
ansible-vault view group_vars/all/vault.yml

# Create encrypted file interactively
ansible-vault create vault.yml

# Re-key (change password)
ansible-vault rekey vault.yml

# Encrypt a single value (useful in CI or templates)
ansible-vault encrypt_string 'mysecret' --name 'super_password'
```

## Vault IDs & Multiple Vaults

- Use `--vault-id` to supply different vault passwords or identity files for different secrets.
- Example: `--vault-id prod@~/.vault_pass_prod --vault-id dev@~/.vault_pass_dev`.
- Store vault IDs in `ansible.cfg` or pass via environment/CI secrets.

## Recommended Patterns

- Keep sensitive data in `group_vars` or `host_vars` encrypted with Vault.
- Use `ansible-vault encrypt_string` to put small secret values directly into `vars` files.
- Use external secret managers (HashiCorp Vault, AWS Secrets Manager, Azure Key Vault) for production systems; use lookup plugins or dynamic fetch inside playbooks.

## CI & Automation

- Do not store vault passwords in the repo.
- In CI, provide the vault password via secure environment variables or a vault password file injected at job runtime.
- For multiple environments, use distinct vault IDs and keys per environment and keep them in a secure secrets manager.

## Example: Using Vault with group_vars

`group_vars/production/vault.yml` (encrypted):
```yaml
ansible_become_pass: !vault |
  $ANSIBLE_VAULT;1.1;AES256
  3762a...
```

Run playbook with vault password file:
```bash
ansible-playbook site.yml --vault-password-file ~/.vault_pass_prod
```

## Alternatives & Hybrid Models

- HashiCorp Vault integration via `hashi_vault` lookup plugin for dynamic secrets.
- External Secrets pattern: fetch secrets at runtime and register them as variables instead of storing in repo.

## Security Notes

- Rotate Vault keys regularly and rotate encrypted values when appropriate.
- Include vault files in backups but protect backup storage with strong access controls.
- Audit access to vault keys and CI secrets.
