#!/usr/bin/env bash
# Эталонное решение linux-46 (для tests/selftest.sh)
set -euo pipefail
setquota -u builder 180M 200M 0 0 /srv/ci
sleep 1
