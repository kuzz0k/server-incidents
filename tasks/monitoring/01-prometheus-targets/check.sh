#!/usr/bin/env bash
set -uo pipefail
TASK_ID=monitoring-01
. "$(dirname "$0")/../../../lib/check.sh"

api() { curl -fsS --max-time 5 "http://127.0.0.1:9090/api/v1/$1"; }
targets_up() {
  api targets | python3 -c '
import json, sys
t = json.load(sys.stdin)["data"]["activeTargets"]
jobs = {}
for x in t:
    jobs.setdefault(x["labels"]["job"], []).append(x["health"])
need = {"prometheus", "node", "app"}
sys.exit(0 if need <= set(jobs) and all(h == "up" for j in need for h in jobs[j]) else 1)'
}
rule_loaded() { api rules | grep -q '"name":"HighDiskUsage"'; }

check "promtool check config без ошибок" promtool check config /etc/prometheus/prometheus.yml
check "prometheus активен" systemctl is-active -q prometheus
echo "  Жду, пока Prometheus опросит цели (до 30 с)…"
wait_until 30 targets_up
check "все цели prometheus, node, app — up" targets_up
check "правило HighDiskUsage загружено" rule_loaded
finish
