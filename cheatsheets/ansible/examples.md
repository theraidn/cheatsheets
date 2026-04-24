# Ansible — Examples & Recipes

A set of practical examples demonstrating common patterns.

## 1) Simple Webserver Deployment

- Install NGINX, deploy a template, and ensure the service is running.

```yaml
- hosts: web
  become: true
  roles:
    - role: mycompany.common

  tasks:
    - name: Install nginx
      package:
        name: nginx
        state: present

    - name: Deploy site config
      template:
        src: templates/site.conf.j2
        dest: /etc/nginx/conf.d/site.conf
      notify: Restart nginx

    - name: Ensure nginx running
      service:
        name: nginx
        state: started
        enabled: true
```

## 2) Rolling Restart (zero-downtime pattern)

- Use `serial` to restart a subset at a time, then wait for health checks.

```yaml
- hosts: web
  serial: 1
  tasks:
    - name: Update app on a single host
      import_role:
        name: webapp
      notify: Restart webapp

    - name: Wait for HTTP 200
      uri:
        # Ansible — Examples & Recipes (Index)

        Practical examples have been split into dedicated files for easier reference and reuse. See the examples directory for individual recipes and deep-dive examples.

        - [01 — Simple Webserver Deployment](examples/01-simple-webserver.md)
        - [02 — Rolling Restart (Zero-downtime Pattern)](examples/02-rolling-restart.md)
        - [03 — Database Migration with Safe Rollback](examples/03-db-migration.md)
        - [04 — Create User with SSH Key](examples/04-create-user-ssh.md)
        - [05 — API Call with register and failed_when](examples/05-api-call.md)
        - [06 — Template with Defaults and Filters](examples/06-template-defaults.md)
        - [07 — Use HashiCorp Vault (Lookup)](examples/07-hashicorp-vault.md)
        - [08 — Quick Debugging Pattern](examples/08-debugging.md)
        - [09 — loop/when Examples](examples/09-loops-and-when-examples.md)

        For language-level constructs (detailed `loop` and `when` usage), see: [constructs/loops-and-when.md](constructs/loops-and-when.md)
  tasks:
