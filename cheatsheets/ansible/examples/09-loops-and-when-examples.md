# Example 9 — `loop` and `when` Examples

This file provides compact, real-world examples showing common `loop` and `when` combinations.

1) Loop over users but skip disabled ones

```yaml
- name: Create enabled users only
  user:
    name: "{{ item.name }}"
    state: present
  loop: "{{ users }}"
  when: item.enabled | default(true)
```

2) Loop over dicts and use `loop_control.label`

```yaml
- name: Ensure services are present
  systemd:
    name: "{{ item.name }}"
    state: started
    enabled: true
  loop: "{{ services }}"
  loop_control:
    label: "{{ item.name }}"
```

3) Register results from a loop and inspect failures

```yaml
- name: Attempt multiple commands
  command: "{{ item.cmd }}"
  loop: "{{ commands }}"
  register: cmd_results

- name: Fail if any command failed
  fail:
    msg: "Command failed: {{ item.item.cmd }}"
  loop: "{{ cmd_results.results }}"
  when: item.rc != 0
```

4) Conditional templating inside loop

```yaml
- name: Render per-host config if enabled
  template:
    src: templates/host.conf.j2
    dest: "/etc/myapp/{{ item.name }}.conf"
  loop: "{{ instances }}"
  when: item.create_config | default(true)
```

5) Using `when` with facts and group membership

```yaml
- name: Debian-specific task
  apt:
    name: htop
    state: present
  when: ansible_facts['os_family'] == 'Debian'

- name: Only run on primary DB hosts
  shell: /usr/local/bin/primary-task
  when: "inventory_hostname == groups['db'][0]"
```

Notes

- Prefer `loop` over legacy `with_items`; `loop` has richer metadata (indexing and `loop_control`).
- Use `loop_control.index_var` to get a 0-based index for each iteration.
- Always guard `when` expressions that may reference undefined vars with `is defined` or `| default(...)`.
