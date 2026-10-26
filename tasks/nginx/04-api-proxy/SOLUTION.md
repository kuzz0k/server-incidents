# nginx-04 · Разбор

## Шаги диагностики
1. `curl -i http://127.0.0.1:8104/api/v1/users` → `400 missing required header X-Forwarded-For` (это ответ бэкенда, не nginx).
2. `journalctl -u api-backend -f` — видно, какие пути и заголовки реально приходят: `/api/v1/users`.
3. Правило `proxy_pass`: **если в `proxy_pass` указан URI** (хотя бы `/`), часть запроса, совпавшая с `location`, заменяется на него.
   `location /api/ { proxy_pass http://b; }` → бэкенд получает `/api/v1/users`.
   `location /api/ { proxy_pass http://b/; }` → бэкенд получает `/v1/users`.
4. Загрузка 2 МБ → `413 Request Entity Too Large` от nginx: по умолчанию `client_max_body_size 1m`.

## Решение
```nginx
server {
    listen 8104;
    client_max_body_size 10m;

    location /api/ {
        proxy_pass http://127.0.0.1:9104/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```
```bash
nginx -t && systemctl reload nginx
```

## Как не допустить снова
- Шаблон proxy-заголовков вынести в `snippets/proxy-params.conf` и подключать через `include`.
- Тесты маршрутов (smoke) после изменения конфига.

## Доп. вопросы на собеседовании
- Чем `$proxy_add_x_forwarded_for` отличается от `$remote_addr`? Можно ли доверять X-Forwarded-For? (`real_ip_header`, `set_real_ip_from`)
- Как проксировать WebSocket? (`proxy_http_version 1.1`, `Upgrade`, `Connection`)
- Что такое `proxy_buffering` и когда его выключают (SSE, стриминг)?
- Какие таймауты есть у proxy? (`proxy_connect_timeout`, `proxy_read_timeout`, `proxy_send_timeout`) Что вернётся при истечении? (504)
- Как сделать rate limiting? (`limit_req_zone`, `limit_conn`)
