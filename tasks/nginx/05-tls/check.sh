#!/usr/bin/env bash
set -uo pipefail
TASK_ID=nginx-05
. "$(dirname "$0")/../../../lib/check.sh"

H=secure.trainer.local
served_cert() { openssl s_client -connect 127.0.0.1:8443 -servername "$H" </dev/null 2>/dev/null | openssl x509 2>/dev/null; }
has_san() { served_cert | openssl x509 -noout -text | grep -q "DNS:$H"; }
valid_30d() { served_cert | openssl x509 -noout -checkend 2592000; }
signed_by_ca() { served_cert > /tmp/.nginx05.pem && openssl verify -CAfile /etc/trainer-ca/ca.crt /tmp/.nginx05.pem; }
redirect_ok() {
  local h
  h=$(curl -sI --max-time 5 "http://$H:8105/x" | tr -d '\r')
  grep -q '^HTTP/[0-9.]* 301' <<<"$h" && grep -qi "^Location: https://$H:8443/x$" <<<"$h"
}

check_body "curl https://$H:8443/ без -k" "secure service ok" "https://$H:8443/"
check "сертификат подписан корпоративным CA" signed_by_ca
check "в SAN есть DNS:$H" has_san
check "сертификат действует ещё больше 30 дней" valid_30d
check "http://$H:8105/x → 301 на https://$H:8443/x" redirect_ok
rm -f /tmp/.nginx05.pem
finish
