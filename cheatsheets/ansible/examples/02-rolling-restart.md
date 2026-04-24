# Example 2 — Rolling Restart (Zero-downtime Pattern)

Goal: Deploy or update an app with minimal disruption by restarting a subset of hosts at a time.

Playbook snippet

```yaml
- name: Rolling deploy webapp
  hosts: web
  serial: 1          # process one host at a time; tune for your cluster
  become: true
  tasks:
    - name: Apply webapp role to host
      import_role:
        name: webapp
      notify: Restart webapp

    - name: Wait for HTTP 200 from local service
      uri:
        url: http://localhost:8080/health
        status_code: 200
        timeout: 5
      register: health
      retries: 10
      delay: 6
      until: health.status == 200

  handlers:
    - name: Restart webapp
      systemd:
        name: webapp
        state: restarted
```

Technical notes

- `serial` controls batch size; `serial: 1` yields conservative zero-downtime behavior but is slower.
- Use a healthcheck (HTTP/port) after each host change to ensure the instance recovered before proceeding.
- Consider `pre_tasks` to drain traffic (e.g., remove node from load balancer) and `post_tasks` to re-add it.
- For cloud autoscaling groups, do not rely solely on `serial`; combine with orchestration or service mesh drains.

Variants

- `serial: 10%` to update a percentage of nodes at a time.
- `strategy: free` can improve concurrency but requires independent tasks.

Verification

- Check the play report per host and confirm `changed` output for intended tasks only.
- Use circuit-breaker/health-check monitoring to ensure the overall service remains healthy during the roll.
