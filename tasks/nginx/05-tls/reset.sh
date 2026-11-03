#!/usr/bin/env bash
# nginx-05: откат — убрать всё, что сделали break.sh и решение, вернуть исходные настройки
set -uo pipefail
TASK_ID=nginx-05
. "$(dirname "$0")/../../../lib/common.sh"

nginx_remove_site secure
hosts_drop '[[:space:]]secure\.trainer\.local$'
# доверие к учебному CA (под любым именем файла)
for f in /usr/local/share/ca-certificates/*.crt; do
  [[ -f $f ]] && openssl x509 -noout -subject -in "$f" 2>/dev/null | grep -q 'Trainer Corp' && rm -f "$f"
done
update-ca-certificates --fresh >/dev/null 2>&1
rm -rf /etc/nginx/ssl /etc/trainer-ca /srv/www/secure
rmdir_empty /srv/www

if nginx -t >/dev/null 2>&1; then nginx_apply || systemctl restart nginx; else warn "nginx -t с ошибкой после отката — проверь конфиг"; fi
exit 0
