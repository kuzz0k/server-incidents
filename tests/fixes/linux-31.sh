#!/usr/bin/env bash
# Эталонное решение linux-31 (для tests/selftest.sh): скрипт из SOLUTION.md
set -euo pipefail
sed -n '/^```bash$/,/^```$/p' "$(dirname "$0")/../../tasks/linux/31-fix-deploy-script/SOLUTION.md" | sed '1d;$d' > /opt/deploy/deploy.sh
chmod 755 /opt/deploy/deploy.sh
