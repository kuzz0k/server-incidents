#!/usr/bin/env bash
# Эталонное решение docker-03 (для tests/selftest.sh): compose.yaml из SOLUTION.md
set -euo pipefail
APP=/opt/trainer-docker/notes
sed -n '/^```yaml$/,/^```$/p' "$(dirname "$0")/../../tasks/docker/03-compose-app-db/SOLUTION.md" | sed '1d;$d' > "$APP/compose.yaml"
