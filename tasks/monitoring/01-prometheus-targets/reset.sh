#!/usr/bin/env bash
# monitoring-01: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=monitoring-01
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit metrics-app
rm -f /etc/prometheus/rules/disk.yml
restore_original /etc/prometheus/rules
restore_original /etc/prometheus/prometheus.yml
systemctl restart prometheus 2>/dev/null || warn "Prometheus не стартовал после отката — проверь journalctl -u prometheus"
exit 0
