# Ansible — Debugging & Troubleshooting

Quick commands and safe techniques to investigate playbook failures.

Ad-hoc checks:
- `ansible all -m ping` — verify connectivity.
- `ansible -m setup <host>` — gather facts for inspection.

Safe playbook testing:
```bash
ansible-playbook site.yml --check --diff -v
```
Use `--check` for dry-run and `--diff` to preview file/template changes.

Common task snippets:
```yaml
- name: Show debug variable
  debug:
    var: some_variable

- name: Fail when a required var is missing
  assert:
    that: "some_variable is defined"
    fail_msg: "some_variable must be provided"
```

Resume and targeted debugging:
- `ansible-playbook playbook.yml --start-at-task='Task Name'`
- Use `--limit` to run a subset of hosts while debugging.

Testing & linting:
- `ansible-lint` to catch policy issues.
- Use `molecule` to test roles locally (Docker/Podman drivers).

Alternative: The Modern Approach
- Use CI to run `ansible-lint`, `ansible-playbook --check`, and `molecule` automatically on PRs.
