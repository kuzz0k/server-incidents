# linux-13 · Разбор

## Шаги диагностики
1. `systemctl status catalog` — `start-limit-hit`, `Start request repeated too quickly`.
2. `journalctl -u catalog -n 50 --no-pager` (или `-f` во время рестартов) — `config parse error ... line 4: 'cache_ttl 300'`.
3. После исправления строки — `required setting DB_HOST is not set`: в конфиге опечатка `DB_HSOT`.
4. `systemctl show catalog -p NRestarts,Restart,StartLimitBurst,StartLimitIntervalUSec` — откуда лимит.

## Решение
```bash
vim /etc/catalog/catalog.conf      # CACHE_TTL=300, DB_HOST=10.0.0.5
systemctl reset-failed catalog     # сбросить счётчик start-limit
systemctl start catalog
journalctl -u catalog -f
```

## Как не допустить снова
- Валидировать конфиг перед рестартом (`nginx -t`, `sshd -t`, свой `--check-config`).
- `ExecStartPre=` с проверкой конфига в юните.
- Выкатывать конфиги через CI/Ansible с проверкой, а не руками.

## Доп. вопросы на собеседовании
- Как работают `Restart=`, `RestartSec=`, `StartLimitBurst=`, `StartLimitIntervalSec=`?
- Зачем `systemctl reset-failed`?
- Как смотреть логи за конкретный период и только ошибки? (`journalctl -u x --since "10 min ago" -p err`)
- Чем `Restart=always` отличается от `on-failure`? Когда что использовать?
- Как сделать, чтобы при падении сервиса приходило уведомление? (`OnFailure=`)
