#!/usr/bin/env bash
# terraform-01: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=terraform-01
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit tf-apply-stuck
pkill -f 'terraform apply' 2>/dev/null
rm -rf /opt/trainer-tf /srv/tf-site
exit 0
