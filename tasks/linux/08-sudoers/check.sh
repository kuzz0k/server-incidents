#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-08
. "$(dirname "$0")/../../../lib/check.sh"

as_deploy() { (cd / && sudo -u deploy sudo -n "$@"); }
denied() { ! as_deploy "$@"; }

check "visudo -c без ошибок" visudo -cq
check "deploy: sudo -n systemctl restart webhook" as_deploy systemctl restart webhook
check "deploy: sudo -n systemctl status webhook" as_deploy systemctl status webhook
check "deploy: sudo -n bash запрещён" denied bash -c true
check "deploy: sudo -n cat /etc/shadow запрещён" denied cat /etc/shadow
check "deploy остался в группе ops" bash -c "id -nG deploy | tr ' ' '\n' | grep -qx ops"
check "правило для %ops на месте" bash -c "grep -rqsE '^%ops[[:space:]]+ALL' /etc/sudoers.d/"
finish
