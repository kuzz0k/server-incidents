#!/usr/bin/env bash
# Эталонное решение linux-22 (для tests/selftest.sh)
set -euo pipefail
. "$(dirname "$0")/../../lib/common.sh"
hosts_drop '^127\.0\.0\.21\s.*api\.payments\.internal'
