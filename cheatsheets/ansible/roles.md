# Ansible — Roles & Reuse

Roles are the recommended mechanism for organizing playbook content into reusable components.

## Directory Layout

Standard role scaffold created by `ansible-galaxy init <role>`:

```
roles/
  myrole/
    defaults/main.yml    # lowest precedence vars
    files/               # files copied with 'copy'
    handlers/main.yml    # handlers
    meta/main.yml        # role metadata and dependencies
    tasks/main.yml       # main task list
    templates/           # jinja2 templates
    tests/
    vars/main.yml        # higher precedence vars
```

## Role Best Practices

- Use `defaults/main.yml` for defaults that can be overridden.
- Use `vars/main.yml` for values that SHOULD NOT be changed by consumers.
- Keep tasks idempotent and small; each task should do one thing.
- Use `meta/main.yml` to declare dependencies on other roles.
- Avoid `include_role` with dynamic paths; keep role interfaces explicit.
- Keep templates generic and pass variables from plays or role defaults.

Example `meta/main.yml` with dependencies:
```yaml
dependencies:
  - role: common
  - role: logging
    vars:
      log_level: DEBUG
```

## Role Inputs & Outputs

- Inputs: `defaults`, `vars` (role), extra-vars, inventory vars, play vars.
- Outputs: created files, changed state, registered variables.

## Role Testing

- Use `molecule` to test roles across multiple platforms.
- Provide `molecule/default/converge.yml` to validate role behavior.

## Role Versioning & Distribution

- Tag releases and publish to Ansible Galaxy using `ansible-galaxy import` or `ansible-galaxy collection` for wider distribution.
- Consider packaging as a collection when you have multiple roles, modules, and plugins.

## Example: Simple role usage in a play

```yaml
- hosts: web
  roles:
    - role: mycompany.nginx
      vars:
        nginx_listen_port: 8080
```

## Role Collections (Ansible Collections)

- Collections group roles, modules, plugins, and playbooks for distribution.
- Install via `ansible-galaxy collection install myorg.mycollection`.
- Recommend separating company-specific roles into collections for release and dependency management.
