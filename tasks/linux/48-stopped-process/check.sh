#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-48
. "$(dirname "$0")/../../../lib/check.sh"

not_stopped() { local pid; pid=$(systemctl show -p MainPID --value quotes-api); [[ $pid != 0 ]] && [[ $(ps -o stat= -p "$pid") != T* ]]; }

check "в ответе правильное состояние" answer_is state T
check_http "GET :8048/health → 200" 200 --max-time 3 http://127.0.0.1:8048/health
check "процесс сервиса не остановлен" not_stopped
finish
