#!/usr/bin/env bash
# Эталонное решение docker-05 (для tests/selftest.sh): Dockerfile из SOLUTION.md
set -euo pipefail
APP=/opt/trainer-docker/reports-api
SOL="$(dirname "$0")/../../tasks/docker/05-dockerfile-optimize/SOLUTION.md"
printf 'test-data/\n.git\n__pycache__/\n*.pyc\n' > "$APP/.dockerignore"
sed -n '/^```dockerfile$/,/^```$/p' "$SOL" | sed '1d;$d' > "$APP/Dockerfile"
