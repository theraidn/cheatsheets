# Example 6 — Template with Defaults and Filters

Goal: Render configuration templates safely with sensible defaults and Jinja2 filters.

Template (`templates/config.j2`)

```
server_port = {{ server_port | default(8080) }}
log_level = {{ log_level | default('INFO') }}
max_workers = {{ max_workers | default(4) }}
```

Playbook snippet

```yaml
- name: Render app configuration
  hosts: app
  vars:
    server_port: 9090
  tasks:
    - name: Render config
      template:
        src: templates/config.j2
        dest: /etc/myapp/config
```

Technical notes

- Use the `default()` filter to avoid undefined variable errors in templates.
- For complex defaults or computed defaults, set them in `defaults/main.yml` of a role.
- To debug template rendering locally, use `ansible-console` or `ansible-playbook --check --diff`.

Security

- Avoid embedding secrets directly in templates. Inject secrets via variables read from Vault or lookup plugins.
- Consider `jinja2` undefined behaviour: set `ANSIBLE_JINJA2_NATIVE` or use `default()` to ensure deterministic rendering.
