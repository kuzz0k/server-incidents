#!/usr/bin/env bash
# Эталонное решение monitoring-01 (для tests/selftest.sh)
set -euo pipefail
sed -i 's/^       description:/          description:/' /etc/prometheus/rules/disk.yml
sed -i "s/localhost:9101/localhost:9100/" /etc/prometheus/prometheus.yml
sed -i "s|metrics_path: /stats|metrics_path: /metrics|" /etc/prometheus/prometheus.yml
promtool check config /etc/prometheus/prometheus.yml >/dev/null
systemctl restart prometheus
sleep 3
