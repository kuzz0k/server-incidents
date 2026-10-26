# linux-22 · Разбор

## Шаги диагностики
1. `curl -v http://api.payments.internal:8022/` — видно, к какому IP идёт подключение: `127.0.0.21`.
2. `getent hosts api.payments.internal` — так резолвит система (с учётом `/etc/hosts`); `dig` тут не поможет: он ходит только в DNS.
3. `grep nsswitch -e hosts /etc/nsswitch.conf` → `files dns`: сначала `/etc/hosts`.
4. `grep api.payments /etc/hosts` — две строки: старый адрес и новый. Срабатывает **первая** подходящая.
5. Где на самом деле API: `ss -ltnp | grep 8022` → `127.0.0.22:8022`.

## Решение
```bash
sed -i '/^127\.0\.0\.21\s.*api\.payments\.internal/d' /etc/hosts
getent hosts api.payments.internal
curl http://api.payments.internal:8022/
```

## Как не допустить снова
- Внутренние имена держать во внутреннем DNS, а не в `/etc/hosts` на каждом сервере.
- Если без hosts никак — управлять файлом через Ansible/Puppet, а не руками.

## Доп. вопросы на собеседовании
- Что задаёт `/etc/nsswitch.conf`? Что будет, если поменять порядок на `dns files`?
- Почему `dig` и `ping` могут показывать разный адрес для одного имени?
- Чем «Connection refused» отличается от «Connection timed out» и «No route to host»?
- Что значит адрес 127.0.0.22? Весь ли 127.0.0.0/8 — loopback?
- Как приложение кеширует DNS? (JVM `networkaddress.cache.ttl`, nscd, systemd-resolved)
