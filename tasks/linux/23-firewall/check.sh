#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-23
. "$(dirname "$0")/../../../lib/check.sh"

rule_8099() { iptables -S 2>/dev/null | grep -- '--dport 8099' | grep -q REJECT; }

check_http "curl :8023/health → 200" 200 http://127.0.0.1:8023/health
check "правило для порта 8099 на месте" rule_8099
systemctl restart fw-hardening >/dev/null 2>&1
check "fw-hardening активен после рестарта" systemctl is-active -q fw-hardening
check_http "после рестарта fw-hardening :8023 доступен" 200 http://127.0.0.1:8023/health
check "после рестарта правило 8099 на месте" rule_8099
finish
