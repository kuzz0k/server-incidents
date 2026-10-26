#!/usr/bin/env bash
# Эталонное решение linux-41 (для tests/selftest.sh): скрипт из SOLUTION.md
set -euo pipefail
sed -n '/^```bash$/,/^```$/p' "$(dirname "$0")/../../tasks/linux/41-onboard-users/SOLUTION.md" | sed -n '1,/^```$/p' | sed '1d;$d' > /usr/local/bin/onboard-users.sh
chmod 755 /usr/local/bin/onboard-users.sh
