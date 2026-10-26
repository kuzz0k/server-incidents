#!/usr/bin/env bash
# Эталонное решение terraform-01 (для tests/selftest.sh)
set -euo pipefail
systemctl disable --now tf-apply-stuck
cd /opt/trainer-tf/site
TF_IN_AUTOMATION=1 terraform apply -input=false -auto-approve -lock-timeout=30s >/dev/null
