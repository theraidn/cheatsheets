# Example 7 — Use HashiCorp Vault (Lookup)

Goal: Fetch secrets from HashiCorp Vault at runtime using the `hashi_vault` lookup plugin.

Example (lookup usage)

```yaml
- hosts: localhost
  gather_facts: no
  tasks:
    - name: Read DB password from Vault
      set_fact:
        db_password: "{{ lookup('community.hashi_vault.hashi_vault', 'secret=secret/data/prod/db token={{ lookup("file", "/etc/vault-token") }} field=password') }}"

    - name: Show masked password
      debug:
        msg: "DB password length: {{ db_password | length }}"
      no_log: true
```

Technical notes

- The `community.hashi_vault.hashi_vault` lookup is provided by the `community.hashi_vault` collection; you must install the collection in control node environments where it will be used.
- Prefer authenticating to Vault with AppRole, Kubernetes auth, or token files injected securely into the runner (CI secret, instance profile, etc.).
- Use `no_log: true` when printing or debugging secret values.

Fallback patterns

- If the lookup plugin is not available, consider a small wrapper script that calls Vault CLI and returns JSON, then call it with the `command` or `shell` module and parse the output (last resort).

Security

- Never store Vault tokens in plaintext in the repository.
- Use short-lived tokens and rotate them regularly.
- Control access to the playbook runner and ensure audit logging for secret fetches.
