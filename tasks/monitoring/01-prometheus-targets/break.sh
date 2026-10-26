#!/usr/bin/env bash
set -euo pipefail
TASK_ID=monitoring-01
. "$(dirname "$0")/../../../lib/common.sh"

install_webapp
remove_unit metrics-app
[[ -f $TASK_VAR/prometheus.yml.orig ]] || cp /etc/prometheus/prometheus.yml "$TASK_VAR/prometheus.yml.orig"
systemctl enable --now prometheus-node-exporter >/dev/null 2>&1 || true

write_unit metrics-app <<EOF
[Unit]
Description=Application with Prometheus metrics

[Service]
DynamicUser=yes
Environment=NAME=metrics-app PORT=8301 METRICS=1
ExecStart=/usr/bin/python3 $WEBAPP
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now metrics-app >/dev/null 2>&1

mkdir -p /etc/prometheus/rules
cat > /etc/prometheus/prometheus.yml <<'EOF'
global:
  scrape_interval: 5s
  evaluation_interval: 5s

rule_files:
  - /etc/prometheus/rules/*.yml

scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ['localhost:9090']

  - job_name: node
    static_configs:
      - targets: ['localhost:9101']

  - job_name: app
    metrics_path: /stats
    static_configs:
      - targets: ['localhost:8301']
EOF
cat > /etc/prometheus/rules/disk.yml <<'EOF'
groups:
  - name: disk
    rules:
      - alert: HighDiskUsage
        expr: (1 - node_filesystem_avail_bytes{fstype!~"tmpfs|overlay|squashfs"} / node_filesystem_size_bytes) * 100 > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Disk {{ $labels.mountpoint }} is {{ $value | humanize }}% full"
       description: "Free some space on {{ $labels.instance }}"
EOF
systemctl restart prometheus >/dev/null 2>&1 || true
