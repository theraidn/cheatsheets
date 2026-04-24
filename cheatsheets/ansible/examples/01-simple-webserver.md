# Example 1 — Simple Webserver Deployment

Goal: Install NGINX, deploy a site configuration from a template, and ensure the service is running and enabled.

Playbook snippet

```yaml
- name: Deploy simple webserver
  hosts: web
  become: true
  vars:
    app_user: webapp
    site_port: 8080
  roles:
    - role: mycompany.common
  tasks:
    - name: Ensure nginx package present
      package:
        name: nginx
        state: present

    - name: Deploy site config
      template:
        src: templates/site.conf.j2
        dest: /etc/nginx/conf.d/site.conf
        owner: root
        mode: '0644'
      notify: Restart nginx

    - name: Ensure nginx running and enabled
      service:
        name: nginx
        state: started
        enabled: true

  handlers:
    - name: Restart nginx
      service:
        name: nginx
        state: restarted
```

Technical notes

- Use `package` for provider independence; if you need provider-specific options (hold, version pin), use `apt` or `yum` explicitly.
- Prefer `template` to `copy` when configuration requires variable interpolation.
- The `notify` → `handler` model ensures handlers run once per play regardless of how many tasks notify them.
- To make templates testable in `--check`, ensure the templating step can render without requiring changed resources (avoid commands inside templates).

Idempotence & verification

- First run should return `changed` for package install and template deployment; subsequent runs should return `changed=0`.

Verify manually:

```bash
ansible web -m service -a "name=nginx state=started" -i inventory
curl -sSfL http://web01.example.com:8080/health
```

Security & hardening

- Run `ansible-lint` and `yamllint` in CI.
- Set `no_log: true` for tasks handling secrets.
- Ensure templates do not leak secrets into logs or artifacts.
