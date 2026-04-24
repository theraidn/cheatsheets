# Ansible — Testing & CI Practices

This document shows how to test playbooks, roles and templates using Ansible core features only — no additional testing frameworks. It focuses on syntax validation, dry-run/check-mode, idempotence checks, role-level smoke tests, and CI integration using `ansible-playbook` and built-in modules.

## Preflight & Syntax Validation

- Syntax check (fast parse):

```bash
ansible-playbook --syntax-check -i inventory playbook.yml
```

- List playbook tasks/hosts/tags without executing:

```bash
ansible-playbook playbook.yml --list-tasks
ansible-playbook playbook.yml --list-hosts
ansible-playbook playbook.yml --list-tags
```

- Quick connectivity / fact checks:

```bash
ansible all -m ping -i inventory
ansible -m setup target.example.com -i inventory
```

## Dry-run (Check Mode) and Template Preview

- Run in check mode with diffs to preview changes. Note: not all modules implement check mode; treat results accordingly.

```bash
ansible-playbook -i inventory playbook.yml --check --diff
```

- To preview rendered templates without making changes, use `--check --diff` and ensure your template tasks support check mode (avoid commands that always change state).

## Idempotence (Two-pass) Testing

- A practical idempotence test is to run the same playbook twice against the same inventory and expect the second run to report `changed=0` for all tasks:

```bash
ansible-playbook -i inventory playbook.yml | tee run1.log
ansible-playbook -i inventory playbook.yml | tee run2.log
# Inspect run2.log for changed counts (expect changed=0 across hosts)
grep -E "changed=[1-9]" run2.log || echo "Idempotent: no changed tasks detected"
```

- For machine-readable summaries, enable the JSON callback and inspect the `stats` block:

```bash
ANSIBLE_STDOUT_CALLBACK=json ansible-playbook -i inventory playbook.yml -v > run.json
# Inspect run.json for the per-host changed counts in the `stats` object
```

## Role-level Smoke Tests (Ansible-only)

Create small, focused smoke tests that run a role on `localhost` (or a disposable test host) and assert expected state using the `assert` and `stat` modules.

Example: `tests/role-smoke-test.yml`

```yaml
- hosts: localhost
  connection: local
  gather_facts: false
  vars:
    tmpfile: /tmp/testfile.txt
  tasks:
    - name: Apply role under test
      import_role:
        name: myrole

    - name: Check file was created by role
      stat:
        path: "{{ tmpfile }}"
      register: tmp

    - name: Assert file exists
      assert:
        that:
          - tmp.stat.exists
        fail_msg: "Role did not create {{ tmpfile }}"
```

- Run the smoke test locally:

```bash
ansible-playbook -i localhost, tests/role-smoke-test.yml
```

## Testing Templates, Handlers and Change Logic

- Use `changed_when` / `failed_when` to make non-idempotent tasks testable and predictable in check mode.
- Validate handlers are triggered only when expected by running with `--check --diff` and by using `--start-at-task` to isolate the change.

Example: force a template render and verify handler notification without side-effects in a dry run.

## Handling External Integrations (APIs, DNS, Cloud)

- Avoid making live external calls in unit-level tests. Instead:
  - Parameterize external endpoints and inject test doubles (local endpoints) via inventory or extra-vars.
  - Use `when:` guards to skip destructive integration steps during unit/smoke runs.

Example: toggle external updates with a variable

```yaml
- name: Update DNS (production only)
  uri:
    url: "https://dns-api.example.com/update"
    method: POST
  when: dns_updates | default(false)
```

Run tests with `-e dns_updates=false` to avoid touching real services.

## CI Integration (Ansible-core only)

- Minimal CI steps using only `ansible-playbook` and `ansible-core` in a container/runner:

```yaml
name: Ansible CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'
      - name: Install ansible-core
        run: pip install 'ansible-core'
      - name: Syntax check
        run: ansible-playbook --syntax-check -i inventory playbook.yml
      - name: Dry run
        run: ansible-playbook -i inventory playbook.yml --check --diff
      - name: Run smoke tests
        run: ansible-playbook -i localhost, tests/role-smoke-test.yml
```

## Observability & Debugging

- Increase verbosity for troubleshooting: `-v`, `-vv`, `-vvv`.
- Persist logs for CI debugging:

```bash
ANSIBLE_LOG_PATH=ansible.log ansible-playbook -i inventory playbook.yml -vvv
```

- Use `ANSIBLE_STDOUT_CALLBACK=json` for machine-readable output when you need to extract per-host statistics programmatically.

## Quick checklist before production run

- `ansible-playbook --syntax-check` ✔
- `ansible all -m ping` ✔
- `ansible-playbook --check --diff` ✔
- Two-pass idempotence run (expect `changed=0` on second run) ✔
- Role smoke tests pass on `localhost` or dedicated test hosts ✔

These practices keep testing fast, deterministic and limited to Ansible core capabilities, avoiding dependency on external testing frameworks while still providing robust validation for playbooks and roles.
