#!/bin/sh

# shellcheck disable=SC3040
set -euo pipefail

echo "System Information"
echo "=================="
echo "Current user: $(id -un)"
echo "Effective UID: $(id -u)"
echo "Hostname: $(hostname)"
echo "Kernel release: $(uname -r)"
echo "System date: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"

echo ""
echo "Disk usage:"
df -h /

echo ""
echo "Memory usage:"
if command -v free >/dev/null 2>&1; then
    free -h
else
    echo "Memory information unavailable: 'free' command not found."
fi

echo ""
echo "Docker daemon status:"
if command -v systemctl >/dev/null 2>&1; then
    if systemctl is-active --quiet docker; then
        echo "Docker daemon: active"
    else
        echo "Docker daemon: inactive"
    fi
elif command -v docker >/dev/null 2>&1; then
    if docker info >/dev/null 2>&1; then
        echo "Docker daemon: active"
    else
        echo "Docker daemon: inactive or unavailable"
    fi
else
    echo "Docker daemon status unavailable: Docker is not installed."
fi