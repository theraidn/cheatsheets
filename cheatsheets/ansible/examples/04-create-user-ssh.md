# Example 4 — Create User with SSH Key

Goal: Create a system user and populate `authorized_keys` from repository or vault-stored public keys.

Playbook snippet

```yaml
- hosts: all
  become: true
  vars:
    users:
      - name: alice
        uid: 1001
        pubkey: files/alice.pub
      - name: bob
        uid: 1002
        pubkey: files/bob.pub
  tasks:
    - name: Create users
      user:
        name: "{{ item.name }}"
        uid: "{{ item.uid }}"
        state: present
        create_home: yes
      loop: "{{ users }}"

    - name: Add authorized key for users
      authorized_key:
        user: "{{ item.name }}"
        key: "{{ lookup('file', item.pubkey) }}"
        state: present
      loop: "{{ users }}"
```

Technical notes

- Use `loop` with lists of dictionaries to keep inputs declarative and readable.
- If public keys are sensitive, store them encrypted (Ansible Vault) or fetch at runtime from a secret manager.
- Use `no_log: true` on tasks that handle private data (never log private keys).
- Ensure correct file permissions on `~/.ssh` and `authorized_keys` — the `authorized_key` module handles this.

Security

- Use `authorized_key` instead of `shell`+`echo` to avoid subtle permission/format issues.
- Avoid storing private keys in the repo; store only public keys or use dynamic retrieval.
