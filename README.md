# DevOps Intern Final

[![CI](https://github.com/abihail22558/devops-intern-final/actions/workflows/ci.yml/badge.svg)](https://github.com/abihail22558/devops-intern-final/actions/workflows/ci.yml)

A simple Nginx application used for the DevOps Intern Final project.

## Project Overview

This project demonstrates containerization, CI/CD automation, DevOps operational practices, and infrastructure orchestration for a simple Nginx web application.

## Application

The application is served using Nginx and displays a simple HTML page.

## Repository Structure

- `index.html` — Application webpage
- `app/Dockerfile` — Container image configuration
- `app/nginx.conf` — Nginx server configuration
- `scripts/sysinfo.sh` — System information script
- `scripts/healthcheck.sh` — Application health check script
- `nomad/nginx-app.nomad.hcl` — Nomad deployment configuration
- `.github/workflows/ci.yml` — Continuous integration workflow
- `README.md` — Project documentation

## DevOps Workflow

The project follows an incremental Git workflow using feature branches and conventional commit messages.

### Branching

- `main` — Stable project branch
- `feature/*` — Development branches for individual changes

### Commit Convention

Commits follow conventional prefixes such as:

- `feat:` — New functionality
- `fix:` — Bug fixes
- `docs:` — Documentation changes
- `ci:` — CI/CD changes

## Linux Scripting

### System Information Script

Run:

```bash
sh scripts/sysinfo.sh

Sample output:

System Information
==================
Current user: abiha
Effective UID: 197610
Hostname: Abihail-Forstys-Life
Kernel release: 3.6.9-b4195d69.x86_64
System date: 2026-09-23T11:07:59Z

Disk usage:
Filesystem             Size  Used Avail Use% Mounted on
C:/ Program Files/Git  476G  142G  335G  30% /

Memory usage:
Memory information unavailable: 'free' command not found.

Docker daemon status:
Docker daemon status unavailable: Docker is not installed.

Note: The memory and Docker messages reflect the Git Bash/Windows environment used for testing. The script reports their availability rather than failing when those Linux-specific tools/services are unavailable.

Application Health Check

Run:
sh scripts/healthcheck.sh https://example.com

Sample successful output:

Application Health Check
========================
Target URL: https://example.com
SUCCESS: Application returned HTTP 200.

The script also correctly handles non-200 responses:

Application Health Check
========================
Target URL: https://example.com/nonexistent-page
ERROR: Application returned HTTP 404; expected HTTP 200.

Application Health Check
========================
Target URL: https://example.com/nonexistent-page
ERROR: Application returned HTTP 404; expected HTTP 200.

The failure case exits with status 1.

Containerisation

The application is packaged as a production-shaped NGINX container using the pinned nginx:1.27-alpine-slim image.

Build the Image

docker build -f app/Dockerfile --build-arg BUILD_SHA="$(git rev-parse --short HEAD)" -t devops-intern-final:task3 .

Run the Container

docker run -d --name devops-intern-final -p 8080:8080 devops-intern-final:task3

Image Size
IMAGE                       ID             DISK USAGE   CONTENT SIZE
devops-intern-final:task3   50fd4472febe   19.4MB       5.45MB

The final image is 19.4 MB, which is below the required 60 MB limit.

Application Response

$ curl -i http://localhost:8080/

HTTP/1.1 200 OK
Server: nginx/1.27.5
Content-Type: text/html
X-Build-SHA: c0c6894

The application is successfully served on port 8080, and the build SHA is exposed through the X-Build-SHA response header.

Health Endpoint

$ curl -i http://localhost:8080/healthz

HTTP/1.1 200 OK
Server: nginx/1.27.5
Content-Type: text/plain
X-Build-SHA: c0c6894

OK

Container Health and Security Verification

The running container reports a healthy Docker health check:

STATUS: Up (healthy)

PORTS: 0.0.0.0:8080->8080/tcp

The container runs as the non-root NGINX user:

uid=101(nginx) gid=101(nginx) groups=101(nginx)

NGINX configuration validation completed successfully:

nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful

Nomad Orchestration

The application is deployed with HashiCorp Nomad using the Docker driver. The job runs one NGINX task and pulls the image published by the CI pipeline from GitHub Container Registry (GHCR).

Job Configuration
Job type: service
Datacenter: dc1
Task group: nginx
Task count: 1
Driver: docker
Image: ghcr.io/abihail22558/devops-intern-final:${var.image_tag}
Image tag: parameterised through the HCL image_tag variable
CPU: 100 MHz
Memory: 64 MB
Network: dynamic port named http, mapped to container port 8080
Consul service: nginx-app
Health check: HTTP GET /healthz
Health check interval: 10s
Health check timeout: 2s
Deployment Strategy

The job uses a rolling deployment configuration with:

max_parallel = 1
min_healthy_time = "10s"
healthy_deadline = "2m"
auto_revert = true

Restart and rescheduling policies are also configured to allow Nomad to recover failed tasks.

Validate and Plan the Job

The job was validated with:

nomad job validate nomad/nginx-app.nomad.hcl

Validation completed successfully. Nomad reported a non-blocking warning about shutdown_delay.

The deployment plan was checked with:

nomad job plan nomad/nginx-app.nomad.hcl

The scheduler dry-run reported that all tasks were successfully allocated.

Run the Job

The job was deployed with:

nomad job run -check-index 0 nomad/nginx-app.nomad.hcl

Nomad reported a successful deployment with one healthy allocation and zero unhealthy allocations.

Verify Job Status

The running deployment was verified with:

nomad job status nginx-app

The result showed:

Status: running
Desired: 1
Running: 1
Healthy: 1
Unhealthy: 0
Latest deployment: successful

The allocation was further verified with:

nomad alloc status d53d7874

The allocation showed:

Client status: running
Deployment health: healthy
Dynamic HTTP address: 127.0.0.1:30281 -> 8080
Task status: running
Total restarts: 0
Consul Service Registration

The service was registered successfully with Consul.

consul catalog services listed nginx-app.

The Consul health endpoint confirmed the service was passing:

curl -s http://127.0.0.1:8500/v1/health/service/nginx-app?passing=true

The nginx-health check reported:

Status: passing
HTTP response: 200 OK
Endpoint: /healthz
Interval: 10s
Timeout: 2s