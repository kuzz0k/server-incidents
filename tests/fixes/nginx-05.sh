#!/usr/bin/env bash
# Эталонное решение nginx-05 (для tests/selftest.sh)
set -euo pipefail
H=secure.trainer.local
cd /etc/nginx/ssl
openssl req -new -newkey rsa:2048 -nodes -keyout secure.key -out secure.csr -subj "/CN=$H" 2>/dev/null
printf 'subjectAltName=DNS:%s\nextendedKeyUsage=serverAuth\n' "$H" > san.ext
openssl x509 -req -in secure.csr -CA /etc/trainer-ca/ca.crt -CAkey /etc/trainer-ca/ca.key \
  -CAcreateserial -days 365 -sha256 -extfile san.ext -out secure.crt 2>/dev/null
cp /etc/trainer-ca/ca.crt /usr/local/share/ca-certificates/trainer-ca.crt
update-ca-certificates >/dev/null
python3 - <<'EOF'
p = "/etc/nginx/sites-available/secure"
s = open(p).read()
s = s.replace("listen 8105;\n    server_name secure.trainer.local;\n    root /srv/www/secure;",
              "listen 8105;\n    server_name secure.trainer.local;\n    return 301 https://secure.trainer.local:8443$request_uri;")
open(p, "w").write(s)
EOF
nginx -t && systemctl reload nginx
sleep 2
