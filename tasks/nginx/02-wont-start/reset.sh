#!/usr/bin/env bash
# nginx-02: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=nginx-02
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit old-landing
nginx_remove_site landing
rm -f /etc/nginx/conf.d/security.conf
rm -rf /srv/www/landing /opt/old-landing
rmdir_empty /srv/www
if nginx -t >/dev/null 2>&1; then systemctl restart nginx; else warn "nginx -t с ошибкой после отката — проверь конфиг"; fi
exit 0
