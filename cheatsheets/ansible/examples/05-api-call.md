# Example 5 — API Call with `register` and `failed_when`

Goal: Call an external API and control failure semantics based on HTTP status or response content.

Playbook snippet

```yaml
- name: Trigger remote API and assert success
  hosts: localhost
  tasks:
    - name: Call external API
      uri:
        url: "https://api.example.com/trigger"
        method: POST
        body: '{"action":"deploy"}'
        body_format: json
        headers:
          Authorization: "Bearer {{ api_token }}"
        timeout: 30
        status_code: 200,202
      register: api_call
      failed_when: api_call.status not in [200, 202]
```

Technical notes

- Use `uri` module over `command: curl` for structured output and idempotence.
- `status_code` can accept a comma-separated list; explicit `failed_when` gives fine-grained control.
- Use `register` to examine `api_call.json` or `api_call.content` for business-level validation.

Retries & Backoff

- To handle transient failures, combine `retries`/`delay` with `until`:

```yaml
- name: Call API with retries
  uri:
    url: https://api.example.com/trigger
    method: POST
    body: '{"action":"deploy"}'
    body_format: json
    headers:
      Authorization: "Bearer {{ api_token }}"
    timeout: 30
  register: api_call
  until: api_call.status in [200,202]
  retries: 5
  delay: 10
```

Security

- Keep `api_token` out of source control (vault or CI secrets).
- Use `no_log: true` on tasks that print tokens or sensitive responses.

Error reporting

- Log `api_call` details to a monitoring service or store them in an artifact for post-mortem.
- Use `failed_when` to transform API-level non-fatal statuses into play failures when appropriate.
