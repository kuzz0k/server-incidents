# nginx-05 · Разбор

## Шаги диагностики
1. `curl -v https://secure.trainer.local:8443/` → `unable to get local issuer certificate`: система не знает CA.
2. Что отдаёт сервер:
   ```bash
   openssl s_client -connect 127.0.0.1:8443 -servername secure.trainer.local </dev/null 2>/dev/null \
     | openssl x509 -noout -subject -issuer -dates -ext subjectAltName
   ```
   Сертификат истёк (`notAfter` в прошлом) и без SAN. Современные клиенты смотрят **только** на SAN, CN игнорируют.
3. `grep ssl_ /etc/nginx/sites-available/secure` — где лежат сертификат и ключ.

## Решение
```bash
cd /etc/nginx/ssl
openssl req -new -newkey rsa:2048 -nodes -keyout secure.key -out secure.csr -subj "/CN=secure.trainer.local"
printf 'subjectAltName=DNS:secure.trainer.local\nextendedKeyUsage=serverAuth\n' > san.ext
openssl x509 -req -in secure.csr -CA /etc/trainer-ca/ca.crt -CAkey /etc/trainer-ca/ca.key \
  -CAcreateserial -days 365 -sha256 -extfile san.ext -out secure.crt
openssl verify -CAfile /etc/trainer-ca/ca.crt secure.crt

# доверие к CA на этом сервере
cp /etc/trainer-ca/ca.crt /usr/local/share/ca-certificates/trainer-ca.crt
update-ca-certificates

# редирект в server-блоке на 8105:
#   return 301 https://secure.trainer.local:8443$request_uri;
nginx -t && systemctl reload nginx
curl https://secure.trainer.local:8443/
curl -I http://secure.trainer.local:8105/x
```
Если сертификат промежуточного CA — в `ssl_certificate` кладётся цепочка: сначала сертификат сайта, потом промежуточный.

## Как не допустить снова
- Мониторинг срока сертификатов (blackbox_exporter `probe_ssl_earliest_cert_expiry`).
- Автоматический выпуск и продление: certbot/ACME, cert-manager в k8s, Vault PKI.

## Доп. вопросы на собеседовании
- Как работает TLS handshake? Что проверяет клиент в сертификате?
- Что такое цепочка доверия и промежуточный сертификат? Что будет, если не отдать intermediate?
- Зачем SNI? Как один IP:порт обслуживает много HTTPS-сайтов?
- Чем PEM отличается от DER и PKCS#12?
- Что такое HSTS и почему его опасно включать сразу с большим max-age?
- Как проверить, что ключ соответствует сертификату? (сравнить modulus / pubkey)
