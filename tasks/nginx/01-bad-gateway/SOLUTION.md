# nginx-01 · Разбор

## Шаги диагностики
1. `curl -i http://127.0.0.1:8101/` → 502. 502 = nginx не смог получить ответ от upstream.
2. `tail /var/log/nginx/error.log` → `connect() failed (111: Connection refused) while connecting to upstream, upstream: "http://127.0.0.1:9101/"`.
3. Бэкенд жив? `systemctl status shop-backend`; где он слушает: `ss -ltnp | grep python` → `9110`.
4. `grep -rn 9101 /etc/nginx/` — upstream в конфиге сайта указывает на старый порт.

## Решение
```bash
sed -i 's/127.0.0.1:9101/127.0.0.1:9110/' /etc/nginx/sites-available/shop
nginx -t && systemctl reload nginx
curl http://127.0.0.1:8101/
```

## Как не допустить снова
- Порты/адреса бэкендов — из одного источника (переменные Ansible, service discovery).
- Health-check бэкенда после деплоя через nginx, а не напрямую.

## Доп. вопросы на собеседовании
- Чем отличаются 502, 503 и 504? Какие из них отдаёт nginx сам?
- Чем `reload` отличается от `restart` для nginx? Что происходит с текущими соединениями?
- Что такое upstream и как nginx балансирует? (round-robin, `least_conn`, `ip_hash`, `max_fails`/`fail_timeout`)
- Где смотреть логи и как включить логирование времени ответа upstream? (`$upstream_response_time`)
- Что такое `proxy_next_upstream`?
