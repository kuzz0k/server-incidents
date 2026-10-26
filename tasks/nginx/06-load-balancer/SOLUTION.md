# nginx-06 · Разбор

## Шаги диагностики
1. `for i in $(seq 9); do curl -s -o /dev/null -w '%{http_code} ' http://127.0.0.1:8106/; done` → `200 200 502 ...`.
2. `error.log`: `connect() failed (111: Connection refused) while connecting to upstream, upstream: "http://127.0.0.1:9163/"`.
3. По умолчанию nginx при ошибке соединения сам повторяет запрос на следующий сервер (`proxy_next_upstream error timeout`),
   но в конфиге стоит `proxy_next_upstream off`. Поэтому каждый запрос, попавший на мёртвый `shop-c`, отдаёт 502.
4. `/report`: в error.log `upstream timed out (110) while reading response header`, а `proxy_read_timeout 5s` меньше времени построения отчёта.

## Решение
```nginx
upstream shop_pool {
    server 127.0.0.1:9161;
    server 127.0.0.1:9162;
    server 127.0.0.1:9163 max_fails=1 fail_timeout=30s;   # пассивный health check
}

server {
    listen 8106;
    proxy_connect_timeout 2s;
    proxy_read_timeout 5s;
    proxy_next_upstream error timeout http_502 http_503;
    proxy_next_upstream_tries 2;

    location / {
        proxy_pass http://shop_pool;
    }

    location /report {
        proxy_pass http://shop_pool;
        proxy_read_timeout 15s;
        proxy_next_upstream error;     # не повторять долгий отчёт на другом бэкенде по таймауту
    }
}
```
```bash
nginx -t && systemctl reload nginx
```
Аккуратно с повтором по `timeout` для неидемпотентных запросов (POST): nginx по умолчанию их не повторяет (`non_idempotent`), и это правильно.

## Доп. вопросы на собеседовании
- Чем 502 отличается от 504? Кто их генерирует?
- Какие алгоритмы балансировки есть в nginx? (round-robin, `least_conn`, `ip_hash`, `hash`, `weight`)
- Чем пассивные health checks (`max_fails`/`fail_timeout`) отличаются от активных? Где есть активные? (nginx Plus, HAProxy, Envoy)
- Что делает `keepalive` в upstream и зачем `proxy_http_version 1.1`?
- Как сделать sticky sessions? Почему их лучше избегать?
- L4 vs L7 балансировка: что умеет L7, чего не умеет L4?
