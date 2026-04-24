# Ansible — Playbooks & Advanced Task Patterns

Playbooks are the primary way to describe desired state. A playbook contains one or more plays; each play targets a set of hosts and executes a list of tasks, handlers, and roles.

## Playbook Anatomy

```yaml
- name: Configure web cluster
  hosts: web
  become: true
  vars:
    app_user: webapp
  roles:
    - role: common
    - role: webapp
  tasks:
    - name: Ensure /var/www exists
      file:
        path: /var/www
        state: directory
        owner: "{{ app_user }}"
```

- `hosts`: target hosts or group name
- `become`: privilege escalation for tasks
- `vars`: play-level variables (lower precedence than extra-vars)
- `roles`: list of roles applied to the play
- `tasks`: ordered list of actions executed on targets

## Handlers

Handlers run when notified (e.g., restart a service after config change):

```yaml
- name: Restart nginx
  service:
    name: nginx
    state: restarted
  listen: "nginx-restart"
```

Notify from task:

```yaml
- template:
    src: templates/nginx.conf.j2
    dest: /etc/nginx/nginx.conf
  notify: "Restart nginx"
```

## Includes vs Imports

- `import_tasks`: static, parsed at playbook parse time.
- `include_tasks`: dynamic, evaluated at runtime (useful with `when` and loops).

## Loops and Iteration

- Modern syntax: `loop:` with `loop_control` and `label` for clearer output.
- Prefer `loop:` over legacy `with_items`.

Example with complex loop and `register`:
```yaml
- name: Create users
  user:
    name: "{{ item.name }}"
    shell: /bin/bash
  loop: "{{ users }}"
  register: user_results

- name: Show created users
  debug:
    var: user_results.results
```

## Error Handling: block / rescue / always

```yaml
- block:
    - name: Do risky operation
      command: /usr/local/bin/risky
  rescue:
    - name: Roll back changes
      command: /usr/local/bin/rollback
  always:
    - name: Always clean temp files
      file:
        path: /tmp/workdir
        state: absent
```

## Delegation and Local Actions

- `delegate_to`: run a task on a different host than the target.
- `run_once`: execute a task only once across all hosts.
- `local_action` / `connection: local`: run on control node.

Example: delegate a DNS update to an API host
```yaml
- name: Update DNS record
  uri:
    url: "https://dns-api.example.com/update"
    method: POST
  delegate_to: localhost
  run_once: true
```

## Asynchronous Tasks

Use `async` and `poll` for long-running operations.

```yaml
- name: Start long job
  shell: /usr/local/bin/backup.sh
  async: 3600
  poll: 0
  register: backup_job

- name: Wait for backup
  async_status:
    jid: "{{ backup_job.ansible_job_id }}"
  register: job_status
  until: job_status.finished
  retries: 30
  delay: 10
```

## Conditional Execution

- Use `when:` expressions to gate execution.
- Example: `when: ansible_facts['os_family'] == 'Debian'`

## Strategy: linear vs free

- `strategy: linear` (default): tasks run in order across hosts.
- `strategy: free`: tasks run independently across hosts; can improve speed but requires idempotent, independent tasks.

## Check Mode & Idempotence

- Test sensitive playbooks with `--check --diff`.
- Use `changed_when` and `failed_when` when module semantics differ from your desired logic.

## Common Flags

- `--tags` / `--skip-tags`
- `--limit`
- `--start-at-task`
- `-e` / `--extra-vars`
- `--become` / `--ask-become-pass`

## Recommendations

- Keep playbooks declarative and high-level; put complex logic in roles or modules.
- Use `import_tasks` for static composition and `include_tasks` for runtime inclusion.
- Prefer pushing templates and letting modules manage service restarts via handlers.
