#!/usr/bin/env bash
# nginx-03: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=nginx-03
. "$(dirname "$0")/../../../lib/common.sh"

nginx_remove_site blog
rm -rf /srv/www/blog /srv/media/images
rmdir_empty /srv/media
[[ -d /srv/www ]] && chmod 0755 /srv/www
rmdir_empty /srv/www

if nginx -t >/dev/null 2>&1; then nginx_apply || systemctl restart nginx; else warn "nginx -t с ошибкой после отката — проверь конфиг"; fi
exit 0
