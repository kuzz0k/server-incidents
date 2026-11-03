#!/usr/bin/env bash
# ansible-01: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=ansible-01
. "$(dirname "$0")/../../../lib/common.sh"

rm -rf /opt/trainer-ansible/status-site /srv/www/status
rm -f /etc/nginx/sites-enabled/status.conf
rmdir_empty /opt/trainer-ansible /srv/www

if nginx -t >/dev/null 2>&1; then nginx_apply || systemctl restart nginx; else warn "nginx -t с ошибкой после отката — проверь конфиг"; fi
exit 0
