#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-27
. "$(dirname "$0")/../../../lib/common.sh"

if systemctl is-active -q chrony 2>/dev/null; then
  systemctl disable --now chrony >/dev/null 2>&1
  touch "$TASK_VAR/had-chrony"
fi
timedatectl set-ntp false 2>/dev/null || true
systemctl stop systemd-timesyncd 2>/dev/null || true
timedatectl set-timezone America/Los_Angeles
date -s "$(date -u -d '-3 days' '+%Y-%m-%d %H:%M:%S') UTC" >/dev/null
