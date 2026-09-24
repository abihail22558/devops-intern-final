# DevOps Intern Final

A simple Nginx application used for the DevOps Intern Final project.

## Project Overview

This project demonstrates containerization, Kubernetes deployment, CI/CD automation, and DevOps operational practices for a simple Nginx web application.

## Application

The application is served using Nginx and displays a simple HTML page.

## Repository Structure

* `index.html` — Application webpage
* `Dockerfile` — Container image configuration
* `simple-nginx-deployment.yaml` — Kubernetes Deployment configuration
* `simple-nginx-service.yaml` — Kubernetes Service configuration
* `README.md` — Project documentation

## DevOps Workflow

The project follows an incremental Git workflow using feature branches and conventional commit messages.

### Branching

* `main` — Stable project branch
* `feature/*` — Development branches for individual changes

### Commit Convention

Commits follow conventional prefixes such as:

* `feat:` — New functionality
* `fix:` — Bug fixes
* `docs:` — Documentation changes
* `ci:` — CI/CD changes

## Linux Scripting

### System Information Script

Run:

```bash
sh scripts/sysinfo.sh
```

Sample output:

```text
System Information
==================
Current user: abiha
Effective UID: 197610
Hostname: Abihail-Forstys-Life
Kernel release: 3.6.9-b4195d69.x86_64
System date: 2026-09-23T11:07:59Z

Disk usage:
Filesystem            Size  Used Avail Use% Mounted on
C:/ Program Files/Git  476G  142G  335G  30% /

Memory usage:
Memory information unavailable: 'free' command not found.

Docker daemon status:
Docker daemon status unavailable: Docker is not installed.
```

> Note: The memory and Docker messages reflect the Git Bash/Windows environment used for testing. The script reports their availability rather than failing when those Linux-specific tools/services are unavailable.

### Application Health Check

Run:

```bash
sh scripts/healthcheck.sh https://example.com
```

Sample successful output:

```text
Application Health Check
========================
Target URL: https://example.com
SUCCESS: Application returned HTTP 200.
```

The script also correctly handles non-200 responses:

```text
Application Health Check
========================
Target URL: https://example.com/nonexistent-page
ERROR: Application returned HTTP 404; expected HTTP 200.
```

The failure case exits with status `1`.

## Containerisation

The application is packaged as a production-shaped NGINX container using the pinned `nginx:1.27-alpine-slim` image.

### Build the Image

```bash
docker build -f app/Dockerfile --build-arg BUILD_SHA="$(git rev-parse --short HEAD)" -t devops-intern-final:task3 .
```

### Run the Container

```bash
docker run -d --name devops-intern-final -p 8080:8080 devops-intern-final:task3
```

### Image Size

```text
IMAGE                       ID             DISK USAGE   CONTENT SIZE
devops-intern-final:task3   50fd4472febe       19.4MB         5.45MB
```

The final image is 19.4 MB, which is below the required 60 MB limit.

### Application Response

```text
$ curl -i http://localhost:8080/

HTTP/1.1 200 OK
Server: nginx/1.27.5
Content-Type: text/html
X-Build-SHA: c0c6894
```

The application is successfully served on port 8080, and the build SHA is exposed through the `X-Build-SHA` response header.

### Health Endpoint

```text
$ curl -i http://localhost:8080/healthz

HTTP/1.1 200 OK
Server: nginx/1.27.5
Content-Type: text/plain
X-Build-SHA: c0c6894

OK
```

### Container Health and Security Verification

The running container reports a healthy Docker health check:

```text
STATUS: Up (healthy)
PORTS: 0.0.0.0:8080->8080/tcp
```

The container runs as the non-root NGINX user:

```text
uid=101(nginx) gid=101(nginx) groups=101(nginx)
```

NGINX configuration validation completed successfully:

```text
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```
