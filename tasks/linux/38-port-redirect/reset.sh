#!/usr/bin/env bash
# linux-38: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=linux-38
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit legacy-billing billing-proxy.socket billing-proxy.service
nat_drop_port 8038
port_listening 8038 && warn "Порт 8038 всё ещё кто-то слушает (прокси из решения?) — останови его вручную: ss -ltnp 'sport = :8038'"
exit 0
