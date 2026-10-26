#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-42
. "$(dirname "$0")/../../../lib/check.sh"

to_mb() { python3 -c 'import re,sys; m=re.search(r"([0-9.]+)\s*([BKMGT])", sys.argv[1]); print(int(float(m.group(1)) * {"B":1/2**20,"K":1/1024,"M":1,"G":1024,"T":2**20}[m.group(2)]))' "$1"; }
usage_ok() { (( $(to_mb "$(journalctl --disk-usage)") <= 200 )); }
max_use_ok() {
  local v; v=$(systemd-analyze cat-config systemd/journald.conf 2>/dev/null | sed -n 's/^\s*SystemMaxUse\s*=\s*//p' | tail -1)
  [[ -n $v ]] && (( $(to_mb "$v") <= 200 ))
}
persistent() {
  local v; v=$(systemd-analyze cat-config systemd/journald.conf 2>/dev/null | sed -n 's/^\s*Storage\s*=\s*//p' | tail -1)
  [[ ${v:-auto} =~ ^(persistent|auto)$ ]] && [[ -d /var/log/journal ]]
}

check "journalctl --disk-usage ≤ 200 МБ" usage_ok
check "SystemMaxUse ≤ 200M" max_use_ok
check "systemd-journald работает" systemctl is-active -q systemd-journald
check "журнал постоянный (на диске)" persistent
finish
