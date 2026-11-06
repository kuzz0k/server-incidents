#!/usr/bin/env bash
# Эталонное решение linux-61 (для tests/selftest.sh)
set -euo pipefail
sudo -u syncer ssh-keygen -R '[127.0.0.1]:2222' >/dev/null 2>&1
ssh-keyscan -p 2222 -t ed25519 127.0.0.1 2>/dev/null | sudo -u syncer tee -a /home/syncer/.ssh/known_hosts >/dev/null
sleep 4
