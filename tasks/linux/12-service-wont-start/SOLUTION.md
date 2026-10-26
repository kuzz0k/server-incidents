# linux-12 · Разбор

## Шаги диагностики
1. `systemctl status orders` — `Failed to load environment files` / `status=203/EXEC`.
2. `journalctl -u orders -n 30 --no-pager` — подробности.
3. `systemctl cat orders` — смотрим юнит целиком (вместе с drop-in'ами).
4. `ls -l /etc/orders/orders.env` — такого файла нет, а настройки лежат в `/etc/default/orders`.
5. `ls -l /usr/bin/python` — нет такого бинаря, в Ubuntu есть только `python3`.
6. `systemd-analyze verify /etc/systemd/system/orders.service` — статическая проверка юнита.

## Решение
```bash
systemctl edit --full orders     # или правим файл в /etc/systemd/system/
#   EnvironmentFile=/etc/default/orders
#   ExecStart=/usr/bin/python3 /usr/local/lib/devops-trainer/webapp.py
systemctl daemon-reload
systemctl enable --now orders
curl http://127.0.0.1:8012/health
```

## Как не допустить снова
- `systemd-analyze verify` в CI для юнитов.
- `EnvironmentFile=-/path` (с минусом), если файл необязательный.
- Полные пути в `ExecStart`, проверенные на целевой ОС.

## Доп. вопросы на собеседовании
- Где лежат юниты: `/lib/systemd/system` vs `/etc/systemd/system` vs `/run/systemd/system`? Что приоритетнее?
- Зачем `daemon-reload`? Что будет, если его забыть?
- Чем `enable` отличается от `start`? Что делает `enable --now`?
- Что такое drop-in (`systemctl edit`) и чем он лучше правки исходного юнита?
- Типы сервисов: `simple`, `exec`, `forking`, `oneshot`, `notify` — чем отличаются?
- Что означают коды `203/EXEC`, `217/USER`, `200/CHDIR`?
