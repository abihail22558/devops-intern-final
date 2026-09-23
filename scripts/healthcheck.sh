#!/bin/sh

# shellcheck disable=SC3040
set -euo pipefail

DEFAULT_URL="http://localhost:8080"
TARGET_URL="${1:-$DEFAULT_URL}"

echo "Application Health Check"
echo "========================"
echo "Target URL: $TARGET_URL"

if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: curl is not installed or not available in PATH." >&2
    exit 1
fi

HTTP_STATUS=$(curl -sS -o /dev/null -w '%{http_code}' "$TARGET_URL")

if [ "$HTTP_STATUS" = "200" ]; then
    echo "SUCCESS: Application returned HTTP 200."
    exit 0
fi

echo "ERROR: Application returned HTTP $HTTP_STATUS; expected HTTP 200." >&2
exit 1