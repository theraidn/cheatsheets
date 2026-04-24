# Example 3 — Database Migration with Safe Rollback

Goal: Run a migration safely on the leader, verify it, and roll back on failure.

Playbook snippet

```yaml
- name: Safe DB migration
  hosts: db
  serial: 1
  become: true
  tasks:
    - name: Run DB migration on leader
      when: inventory_hostname == groups['db'][0]
      command: /usr/local/bin/migrate.sh
      register: migrate
      changed_when: migrate.rc == 0 and migrate.stdout | search('migrations applied')
      failed_when: migrate.rc != 0

    - block:
        - name: Verify DB schema
          command: /usr/local/bin/check-schema.sh
          register: check
          failed_when: check.rc != 0
      rescue:
        - name: Rollback migration
          command: /usr/local/bin/rollback.sh
          when: migrate.changed
        - name: Fail the play
          fail:
            msg: "Migration failed and rollback executed"
      always:
        - name: Notify monitoring
          uri:
            url: "https://monitoring.example.com/events"
            method: POST
            body: "{ \"migration\": \"completed\" }"
            status_code: 200
```

Technical notes

- Run migrations on one host (`serial: 1`) to avoid race conditions.
- Use `register` to capture command output and `failed_when`/`changed_when` to encode business logic.
- `block/rescue/always` mirrors try/catch semantics and is safer than ad-hoc error handling.
- Use idempotent migration scripts where possible so repeated runs safely skip applied migrations.

Verification & audit

- Store migration outputs (`migrate.stdout`) in logs or a persistent audit store.
- Tag releases so you can tie migrations to a specific code revision.

Rollback considerations

- Ensure `rollback.sh` is non-destructive for unaffected data, and always test rollback paths in staging.
- If using DB replicas, consider failing over back to read-only replicas while migration is being validated.
