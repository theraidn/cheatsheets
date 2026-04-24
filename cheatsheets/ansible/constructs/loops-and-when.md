# Ansible — Loops & When (Detailed Guide)

This guide explains `loop` mechanics, `loop_control`, `register` interactions, and the `when` conditional system in depth, with practical examples and common pitfalls.

1) `loop` basics

- Syntax:
  - `loop: [1,2,3]` or `loop: "{{ my_list }}"`
  - Each iteration exposes `item` (default name) unless overridden with `loop_control.loop_var`.

- Prefer `loop` over legacy `with_items` (deprecated). `loop` exposes richer metadata and coheres better with new Ansible features.

Example: iterate a list of dicts

```yaml
- name: Create users
  user:
    name: "{{ item.name }}"
    uid: "{{ item.uid }}"
  loop: |
    - { name: alice, uid: 1001 }
    - { name: bob, uid: 1002 }
```

2) `loop_control`

- `index_var`: capture a numeric index (0-based) for each iteration.
- `label`: customize how Ansible prints the looped item in output.
- `loop_var`: change `item` name to avoid clashes (e.g., when nested loops use `item`).

Example:

```yaml
- name: Install packages with index
  package:
    name: "{{ item }}"
    state: present
  loop:
    - nginx
    - redis
  loop_control:
    index_var: pkg_idx
    label: "{{ item }} (index {{ pkg_idx }})"
```

3) `register` with loops

- Registering a task with a loop stores the per-iteration results in `registered_var.results`.
- Each element in `results` includes `item`, `rc`, `stdout`, `stderr`, `changed`, etc.

Example: inspect failures

```yaml
- name: Run several commands
  command: "{{ item.cmd }}"
  loop: "{{ commands }}"
  register: cmd_results

- name: Report failing commands
  debug:
    msg: "Command {{ item.item.cmd }} failed with rc={{ item.rc }}"
  loop: "{{ cmd_results.results }}"
  when: item.rc != 0
```

4) Nested loops

- Use `loop` with Jinja2 `product()` or `subelements` lookups; take care with `item` naming (`loop_control.loop_var`).

Example using `product`:

```yaml
- name: Combine two lists
  debug:
    msg: "pair={{ item }}"
  loop: "{{ mylist1 | product(mylist2) | list }}"
  loop_control:
    label: "{{ item }}"
```

5) `when` conditional expressions

- `when:` accepts a single expression or a list of expressions (all must be true).
- Expressions use Jinja2 syntax; you can use `and`, `or`, `not`.
- Protect against undefined variables: use `is defined` or `| default(...)`.

Examples:

```yaml
- name: Debian specific
  apt:
    name: htop
  when: ansible_facts['os_family'] == 'Debian'

- name: Complex condition
  debug:
    msg: "Proceed"
  when:
    - myvar is defined
    - myvar | int > 0
    - "'web' in group_names"
```

6) Combining `when` and `loop`

- `when` may reference `item` when used with `loop`.
- If a `when` expression fails for an item, that iteration is skipped (not marked failed).

Example:

```yaml
- name: Create only enabled users
  user:
    name: "{{ item.name }}"
  loop: "{{ users }}"
  when: item.enabled | default(true)
```

7) Common pitfalls & best practices

- Pitfall: `when: some_var` can error if `some_var` is undefined. Use `when: some_var is defined and some_var` or `when: some_var | default(false)`.
- Pitfall: Overwriting `item` in nested loops; use `loop_control.loop_var` to disambiguate.
- Use `loop_control.label` to produce readable logs for complex structures.
- Prefer explicit boolean checks (`==`, `in`) over truthy/falsey semantics for clarity.

8) Performance considerations

- Large loops can increase task runtime. Where possible, push batching into modules (e.g., `package: name: [a,b,c] state: present`) rather than looping per-package.
- When calling external APIs in loops, prefer batch APIs or backoff/retry logic with `until` to avoid rate limits.

9) Debugging techniques

- Inspect `registered_var.results` with `debug: var=` to see per-item outputs.
- Use `loop_control.index_var` to add deterministic IDs for correlated logging or artifact names.

These constructs are fundamental for writing clear, maintainable playbooks. Use them together (loops, registers, when, loop_control) to model complex orchestration reliably.
