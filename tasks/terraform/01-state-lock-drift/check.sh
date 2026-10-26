#!/usr/bin/env bash
set -uo pipefail
TASK_ID=terraform-01
. "$(dirname "$0")/../../../lib/check.sh"

P=/opt/trainer-tf/site
export TF_IN_AUTOMATION=1
no_tf() { ! pgrep -x terraform >/dev/null; }
stuck_off() { ! systemctl is-active -q tf-apply-stuck && ! systemctl is-enabled -q tf-apply-stuck 2>/dev/null; }
plan_clean() { (cd "$P" && terraform plan -input=false -lock-timeout=10s -detailed-exitcode >/dev/null 2>&1); }
lineage_same() { [[ $(python3 -c 'import json; print(json.load(open("'"$P"'/terraform.tfstate"))["lineage"])' 2>/dev/null) == "$(cat "$TASK_VAR/lineage")" ]]; }
files_match() { cmp -s /srv/tf-site/app.conf "$TASK_VAR/app.conf.expected" && grep -qx 'Managed by Terraform (prod)' /srv/tf-site/motd; }

check "процессов terraform нет" no_tf
check "зависший запуск выключен" stuck_off
check "terraform plan: изменений нет" plan_clean
check "файлы соответствуют коду (prod)" files_match
check "state тот же (lineage не изменился)" lineage_same
finish
