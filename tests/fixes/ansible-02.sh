#!/usr/bin/env bash
# Эталонное решение ansible-02 (для tests/selftest.sh): плейбук из SOLUTION.md
set -euo pipefail
sed -n '/^```yaml$/,/^```$/p' "$(dirname "$0")/../../tasks/ansible/02-idempotency/SOLUTION.md" | sed '1d;$d' > /opt/trainer-ansible/base/base.yml
