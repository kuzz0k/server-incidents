#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-05
. "$(dirname "$0")/../../../lib/check.sh"

MP=/srv/app

check "$MP смонтирован с vgapp/data" bash -c "findmnt -n -o SOURCE $MP | grep -q vgapp-data"
check "LV vgapp/data ≥ 700 MiB" bash -c "(( \$(lvs --noheadings --nosuffix --units m -o lv_size vgapp/data | tr -d ' ' | cut -d. -f1) >= 700 ))"
check "ФС в $MP ≥ 650 MiB" bash -c "(( \$(df --output=size -m $MP | tail -1 | tr -d ' ') >= 650 ))"
check "занято меньше 60%" bash -c "(( \$(df --output=pcent $MP | tail -1 | tr -dc 0-9) < 60 ))"
check "данные не изменились" bash -c "cd $MP && sha256sum -c --quiet $TASK_VAR/data.sha256"
finish
