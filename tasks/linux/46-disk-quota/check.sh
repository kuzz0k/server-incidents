#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-46
. "$(dirname "$0")/../../../lib/check.sh"

MP=/srv/ci
quota_on() { quotaon -pu "$MP" 2>/dev/null | grep -q 'is on'; }
hard_ok() {
  local kb
  kb=$(repquota -u "$MP" 2>/dev/null | awk '$1 == "builder" {print $5}')
  [[ -n $kb ]] && (( kb >= 200 * 1024 ))
}

check "квоты на $MP включены" quota_on
check "hard-лимит builder ≥ 200 МБ" hard_ok
check "артефакты на месте" bash -c "cd $MP/artifacts && sha256sum -c --quiet $TASK_VAR/artifacts.sha256"
check "ci-runner активен" systemctl is-active -q ci-runner
check_http "GET :8046/health → 200" 200 http://127.0.0.1:8046/health
finish
