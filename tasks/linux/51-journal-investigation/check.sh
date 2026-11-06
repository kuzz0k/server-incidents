#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-51
. "$(dirname "$0")/../../../lib/check.sh"

check "error_order" answer_is error_order "$(cat "$TASK_VAR/order")"
check "error_time" answer_is error_time "$(cat "$TASK_VAR/time")"
check "restarts" answer_is restarts "$(cat "$TASK_VAR/restarts")"
check "exit_code" answer_is exit_code 3
finish
