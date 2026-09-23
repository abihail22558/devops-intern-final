# DevOps Intern Final

A simple Nginx application used for the DevOps Intern Final project.

## Project Overview

This project demonstrates containerization, Kubernetes deployment, CI/CD automation, and DevOps operational practices for a simple Nginx web application.

## Application

The application is served using Nginx and displays a simple HTML page.

## Repository Structure

- `index.html` — Application webpage
- `Dockerfile` — Container image configuration
- `simple-nginx-deployment.yaml` — Kubernetes Deployment configuration
- `simple-nginx-service.yaml` — Kubernetes Service configuration
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
C:/Program Files/Git  476G  142G  335G  30% /

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


