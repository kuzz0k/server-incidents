#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-34
. "$(dirname "$0")/../../../lib/check.sh"

U=search-reindex
unit_ok() { [[ $(answer_get unit) =~ ^search-reindex(\.service)?$ ]]; }
io_class() { [[ $(systemctl show -p IOSchedulingClass --value "$U") =~ ^(idle|3)$ ]]; }
nice_ok() { (( $(systemctl show -p Nice --value "$U") >= 10 )); }
proc_idle() { local pid; pid=$(systemctl show -p MainPID --value "$U"); [[ $pid != 0 ]] && ionice -p "$pid" | grep -q idle; }

check "в ответе правильный юнит" unit_ok
check "$U активен" systemctl is-active -q "$U"
check "в юните IOSchedulingClass=idle" io_class
check "в юните Nice ≥ 10" nice_ok
check "у процесса класс I/O idle" proc_idle
finish
