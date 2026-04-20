# Docker — Best Practices & Quick Commands

- Build with cache control and pull latest base:
```bash
docker build --pull --tag myapp:latest .
```

- Multi-stage build example (keep images small):
```dockerfile
FROM golang:1.20 AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o myapp ./...

FROM gcr.io/distroless/static:nonroot
COPY --from=builder /app/myapp /usr/local/bin/myapp
ENTRYPOINT ["/usr/local/bin/myapp"]
```

- Scan images for vulnerabilities (CI):
```bash
trivy image --severity HIGH,CRITICAL myimage:latest
```

- Run ephemeral container for quick checks:
```bash
docker run --rm -it -p 8080:8080 --name myapp myimage:latest
```

Alternative: The Modern Approach
- Consider Podman for rootless containers and `buildx` for cross-platform builds.
