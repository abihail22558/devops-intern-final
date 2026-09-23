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
