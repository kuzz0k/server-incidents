#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-26
. "$(dirname "$0")/../../../lib/common.sh"

SWAP=/var/lib/swap/trainer.swap
swapoff "$SWAP" 2>/dev/null || true
rm -f "$SWAP"
sed -i '\|/var/lib/swap/trainer.swap|d' /etc/fstab
grep -rlsE '^\s*vm\.swappiness' /etc/sysctl.conf /etc/sysctl.d/ | while read -r f; do
  sed -i -E 's/^(\s*vm\.swappiness)/# \1/' "$f"
done
sysctl -qw vm.swappiness=60
