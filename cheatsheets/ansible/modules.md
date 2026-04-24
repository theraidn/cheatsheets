# Ansible — Modules & When to Use Them

Use modules wherever possible: they encapsulate idempotence and check-mode support. Avoid `shell`/`command` unless a module cannot do the job.

## Commonly Used Modules

- File management: `file`, `copy`, `template`, `fetch`, `synchronize`
- Package management: `apt`, `yum`, `dnf`, `package`, `pip`, `npm`
- Service management: `service`, `systemd` (preferred), `supervisorctl`
- User/group: `user`, `group`, `authorized_key`
- Networking: `iptables`, `ufw`, `firewalld`, `nmcli`
- Cloud & infra: many provider modules (ec2, gce, azure_rm, k8s)
- Orchestration: `command`, `shell`, `raw` (use sparingly)

## Command vs Shell vs Raw

- `command`: safer; no shell features (no pipes, redirects). Use when you don't need shell expansion.
- `shell`: runs through a shell; required for shell constructs. Be careful with quoting and idempotence.
- `raw`: sends the command directly over SSH and does not use a module; used for bootstrapping when Python isn't present.

## Idempotence & Check Mode

- Prefer modules that implement `check_mode`; test with `--check`.
- If a module does not support `check_mode`, use `changed_when` / `failed_when` to control results.

## Writing Custom Modules

- Use Python and `ansible.module_utils.basic.AnsibleModule`.
- Return JSON with at least `changed` and optionally `msg`, `failed`, and `rc`.
- Use `ansible-test` and unit tests when adding modules to collections.

Minimal example (python module):
```python
from ansible.module_utils.basic import AnsibleModule

module = AnsibleModule(argument_spec={ 'name': {'required': True, 'type': 'str'} })
name = module.params['name']
# Implement idempotent logic
module.exit_json(changed=False, msg=f"Hello {name}")
```

## Module Utilities & Helpers

- Use lookups (`lookup('file', 'path')`) and filters (`| default('value')`, `| combine(...)`) inside templates and vars.
- Use `ansible.builtin.uri` for HTTP APIs instead of `shell`/`curl`.

## Choosing Modules for System Changes

- Manage packages with `package` (generic) or provider-specific modules (`apt`, `yum`).
- Manage services with `systemd` for systemd systems — it understands unit state and restart semantics.

## Module Documentation

- Use `ansible-doc <module>` to read local module docs.

```bash
ansible-doc apt
ansible-doc -s lineinfile   # show short description
```
