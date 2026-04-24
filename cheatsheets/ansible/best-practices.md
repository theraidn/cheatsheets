# Ansible — Best Practices

Concise, practical recommendations to make your Ansible code reliable, maintainable, and secure.

## General Principles

- Keep tasks small and specific — easier to test and reason about.
- Prefer modules over raw `shell`/`command`.
- Idempotence is critical — running a playbook multiple times should converge to the same state.
- Avoid side-effects in templates and handlers when possible.
- Use variables and defaults to make roles configurable.

## Variables & Secrets

- Use `defaults` for overridable values and `vars` for internal role values.
- Do not commit secrets to the repository — use `ansible-vault` or external secret managers.
- Avoid deeply nested variable name collisions by using role namespaces (e.g., `myrole_db_user`).

## Role Design

- Roles should be small, focused, and composable.
- Use `meta/main.yml` for role dependencies.
- Document role inputs (expected variables) and outputs (generated artifacts/secrets).

## Playbook Structure

- Keep top-level playbooks orchestration-focused (call roles and limited tasks).
- Complex logic belongs in roles or modules, not in playbooks.

## Idempotence Patterns

- Use `creates`, `removes` on command or script tasks when a module is not available.
- Use `changed_when: false` for read-only tasks.
- Use `register` and `when` to gate follow-up tasks reliably.

## Security

- Run `ansible-lint` to detect potential security issues.
- Reduce privileges: use `become` only where necessary and use `become_user` when appropriate.
- Use `no_log: true` for tasks that handle secrets to avoid logging sensitive information.

## Performance

- Batch hosts with `serial` to limit blast radius for changes.
- Use `forks` and `pipelining` to speed up parallel execution.
- Cache facts if gathering facts is expensive in your environment.

## Documentation & Discoverability

- Include README for roles and complex playbooks with example usage, variables, and expected outcomes.
- Add `tags` to high-level tasks to allow partial runs during maintenance.

## Change Management

- Use CI to validate playbooks and roles before merge.
- Tag role releases and pin role versions in requirements files for reproducible runs.

## Example Checklist Before Running in Production

- Run `ansible-lint`.
- Run `ansible-playbook --check --diff` in staging.
- Verify secrets and vault access in CI.
- Run `molecule test` for roles and `integration` scenarios.
