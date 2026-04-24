# Ansible — Overview & Core Concepts

Ansible is an agentless automation framework that uses SSH (or other connection plugins) to run small programs (modules) on managed nodes, returning structured JSON results to the control node. This cheat sheet covers the control flow, core concepts, and operational knobs that matter when writing robust, production-ready automation.

## Execution Model

- Control node runs `ansible`/`ansible-playbook` and pushes modules to managed nodes.
- Modules are executed on managed nodes and return JSON to the control node.
- No persistent agent required on managed nodes (agentless).

## Key Concepts

- Inventory: list of hosts (static or dynamic), can be INI, YAML, or plugin-derived.
- Playbook: YAML document that maps hosts to tasks and roles.
- Role: reusable unit with a defined directory layout (`tasks`, `handlers`, `templates`, `files`, `vars`, `defaults`, `meta`).
- Module: unit of work (e.g., `file`, `template`, `apt`, `yum`, `systemd`). Prefer modules over `shell`/`command` for idempotence.
- Facts: discovered system information (gather_facts: true/false). Cache facts for speed in large environments.
- Plugins: callbacks, connections, lookups, filters, vars, inventory, cache, action, httpapi.

### Fundamental Components

- **Handlers**: Special tasks triggered by `notify` from other tasks. Handlers run once at the end of a play (or when their notifier executes) and are typically used for operations like restarting services. Example:

```yaml
notify: Restart nginx
...
handlers:
- name: Restart nginx
  service:
    name: nginx
    state: restarted
```

- **Roles**: Reusable, opinionated directory layouts that group related automation (`tasks`, `handlers`, `templates`, `files`, `vars`, `defaults`, `meta`). Roles encapsulate behavior and expose configuration through `defaults` and `vars`, making playbooks composable and maintainable.

- **Modules**: The executable units of work that run on target hosts (e.g., `file`, `template`, `systemd`, `apt`). Prefer modules over `shell`/`command` because they implement idempotence and `check_mode` support; modules return structured JSON and can be invoked ad‑hoc with `ansible -m`.

## Inventory Types

- Static file: `hosts.ini` or `hosts.yml` with groups and variables.
- Directory-based: `inventory/` with `group_vars/` and `host_vars/`.
- Dynamic: inventory scripts or inventory plugins (cloud providers, LDAP, etc.).

Example `hosts.yml` snippet:
```yaml
all:
  children:
    web:
      hosts:
        web01.example.com:
          ansible_user: ubuntu
    db:
      hosts:
        db01.example.com:
```

## Variable Precedence (low → high)

1. Role defaults (roles/role/defaults/main.yml)
2. Inventory vars (group_vars/ and host_vars/)
3. Playbook group_vars/host_vars (inventory)
4. Play vars (vars: in plays)
5. Role vars (roles/role/vars/main.yml)
6. Block vars (vars inside blocks)
7. Task vars (vars set within a task)
8. Registered vars and `set_fact`
9. Extra vars (`ansible-playbook -e`) — highest precedence

## Important `ansible.cfg` settings

```ini
[defaults]
inventory = ./inventory
host_key_checking = False
forks = 50
retry_files_enabled = False
deprecation_warnings = False
roles_path = ./roles
# fact_caching = jsonfile
# fact_caching_connection = /tmp/ansible_facts

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
pipelining = True  # reduces SSH overhead, but disables shell-wide sudo prompts
```

## Performance & Scaling

- Increase `forks` for parallelism, but monitor control node and network load.
- Use `pipelining` to reduce SSH round-trips (requires modules support and may affect privilege escalation).
- Enable fact caching (memory/redis/jsonfile) to avoid repeated `setup` calls.
- Use `strategy: free` to run independent tasks on hosts in parallel where safe.

## Idempotence & Check Mode

- Prefer modules that correctly implement `check_mode`; verify with `--check`.
- Validate templates and handlers do not produce side effects when in check mode.
- Use `changed_when` / `failed_when` to shape idempotence when modules don't provide it.

## Common Commands

```bash
# Run playbook (verbose)
ansible-playbook site.yml -v

# Dry-run and show diffs
ansible-playbook site.yml --check --diff

# Run ad-hoc command
ansible web -m shell -a 'uptime'

# Ping all hosts
ansible all -m ping

# Lint playbooks and roles
ansible-lint .
```

## Tips

- Use `--limit` and `--start-at-task` for targeted debugging.
- Use tags for grouping tasks: `--tags deploy` or `--skip-tags debug`.
- Avoid storing secrets in plaintext; integrate with Ansible Vault or external secret managers.
- Keep tasks small and focused to make failures easier to diagnose.

## Where to go next
See detailed topics: playbook patterns, role layout, vault usage, module selection, testing, and examples in this directory. Also consult the debugging guide at `debugging/troubleshooting.md`.
