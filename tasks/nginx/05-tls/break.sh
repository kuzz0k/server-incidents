#!/usr/bin/env bash
set -euo pipefail
TASK_ID=nginx-05
. "$(dirname "$0")/../../../lib/common.sh"

H=secure.trainer.local
rm -f /usr/local/share/ca-certificates/trainer-ca.crt
update-ca-certificates --fresh >/dev/null 2>&1
rm -rf /etc/trainer-ca /etc/nginx/ssl
mkdir -p /etc/trainer-ca /etc/nginx/ssl /srv/www/secure
chmod 0700 /etc/trainer-ca
echo "<h1>secure service ok</h1>" > /srv/www/secure/index.html

hosts_drop "[[:space:]]$H\$"
echo "127.0.0.1 $H" >> /etc/hosts

# Корпоративный CA
openssl req -x509 -newkey rsa:2048 -nodes -days 3650 -sha256 \
  -keyout /etc/trainer-ca/ca.key -out /etc/trainer-ca/ca.crt \
  -subj "/O=Trainer Corp/CN=Trainer Corp Internal CA" 2>/dev/null

# Просроченный сертификат без SAN (через openssl ca, чтобы задать даты в прошлом)
w=$(mktemp -d)
touch "$w/index.txt"; echo 1000 > "$w/serial"; mkdir "$w/new"
cat > "$w/ca.cnf" <<EOF
[ ca ]
default_ca = tca
[ tca ]
database = $w/index.txt
new_certs_dir = $w/new
serial = $w/serial
default_md = sha256
policy = pany
unique_subject = no
[ pany ]
commonName = supplied
EOF
openssl req -new -newkey rsa:2048 -nodes -keyout /etc/nginx/ssl/secure.key \
  -out "$w/site.csr" -subj "/CN=$H" 2>/dev/null
openssl ca -batch -config "$w/ca.cnf" -cert /etc/trainer-ca/ca.crt -keyfile /etc/trainer-ca/ca.key \
  -in "$w/site.csr" -out /etc/nginx/ssl/secure.crt -notext \
  -startdate 20250101000000Z -enddate 20250401000000Z >/dev/null 2>&1
rm -rf "$w"
chmod 0600 /etc/nginx/ssl/secure.key

nginx_site secure <<EOF
server {
    listen 8105;
    server_name $H;
    root /srv/www/secure;
}

server {
    listen 8443 ssl;
    server_name $H;
    ssl_certificate     /etc/nginx/ssl/secure.crt;
    ssl_certificate_key /etc/nginx/ssl/secure.key;
    root /srv/www/secure;
}
EOF
nginx_apply || die "nginx не применил конфиг"
