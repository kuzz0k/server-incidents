# nginx-02 · Разбор

## Шаги диагностики
1. `systemctl status nginx`, `journalctl -u nginx -n 30`.
2. **Всегда** `nginx -t` → `invalid number of arguments in "server_tokens" directive in /etc/nginx/conf.d/security.conf:1`: пропущена `;`, и следующая строка «склеилась» с этой.
3. После исправления `nginx -t` OK, но старт падает: `bind() to 0.0.0.0:8102 failed (98: Address already in use)`.
4. `ss -ltnp 'sport = :8102'` → python3, `systemctl status <PID>` → `old-landing.service`.

## Решение
```bash
sed -i 's/^server_tokens off$/server_tokens off;/' /etc/nginx/conf.d/security.conf
nginx -t
systemctl disable --now old-landing
systemctl restart nginx
curl -I http://127.0.0.1:8102/
```

## Как не допустить снова
- `nginx -t` перед каждым reload/restart (в CI и в Ansible handler'ах: `validate: nginx -t -c %s`).
- Использовать `reload`, а не `restart`: с битым конфигом reload не уронит работающий nginx.

## Доп. вопросы на собеседовании
- Чем `nginx -s reload` отличается от `restart`? Что будет при reload с ошибкой в конфиге?
- Как устроены master и worker процессы nginx?
- Порядок include: `nginx.conf` → `conf.d/*.conf` → `sites-enabled/*`. Чем `sites-available` отличается от `sites-enabled`?
- Что делают `server_tokens`, `add_header ... always`? Какие ещё security-заголовки знаешь? (HSTS, CSP, X-Content-Type-Options)
- Почему `add_header` из `http {}` не работает, если в `location` есть свой `add_header`?
