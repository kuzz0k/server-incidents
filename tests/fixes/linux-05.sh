#!/usr/bin/env bash
# Эталонное решение linux-05 (для tests/selftest.sh)
set -euo pipefail
. "$(dirname "$0")/../../lib/common.sh"
dev=$(disk_dev linux05-c)
pvcreate -qq "$dev"
vgextend -qq vgapp "$dev"
lvextend -qq -r -l +100%FREE vgapp/data
