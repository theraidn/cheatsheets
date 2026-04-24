# Example 8 — Quick Debugging Pattern

Goal: Fast, local debugging snippets to inspect variables, hostvars, and task outputs.

Common tasks

```yaml
- name: Dump host variables for current host
  debug:
    var: hostvars[inventory_hostname]

- name: Print a single variable with fallback
  debug:
    msg: "Value: {{ some_var | default('MISSING') }}"

- name: Show registered results
  debug:
    var: some_registered_var
```

Command-line helpers

```bash
# Run a single debug ad-hoc command across hosts
ansible all -m debug -a 'var=ansible_facts' -i inventory

# Run playbook start at a specific task
ansible-playbook playbook.yml --start-at-task='Task Name'

# Limit to a host or group for focused debugging
ansible-playbook playbook.yml --limit web01.example.com
```

Advanced tips

- Use `-vvv` to get module return values in detail from `ansible-playbook`.
- Use `ANSIBLE_STDOUT_CALLBACK=json` for machine-readable outputs useful for post-processing.
- Temporarily add `no_log: false` to reveal variables (but remove or secure before committing).
- For templating issues, render templates locally or use `template` into a temporary location and inspect the output.
