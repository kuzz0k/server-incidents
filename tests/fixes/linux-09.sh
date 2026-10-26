#!/usr/bin/env bash
# Эталонное решение linux-09 (для tests/selftest.sh)
set -euo pipefail
chmod 755 /home/alice
chown -R alice:alice /home/alice/.ssh
chmod 700 /home/alice/.ssh
chmod 600 /home/alice/.ssh/authorized_keys
usermod -s /bin/bash alice
