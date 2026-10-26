#!/usr/bin/env bash
# Эталонное решение linux-08 (для tests/selftest.sh)
set -euo pipefail
mv /etc/sudoers.d/deploy.conf /etc/sudoers.d/zz-deploy
chmod 440 /etc/sudoers.d/zz-deploy
visudo -c
