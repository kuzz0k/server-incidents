# linux-42 · Разбор

## Шаги
1. Сколько занимает: `journalctl --disk-usage`, `du -sh /var/log/journal`.
2. Откуда лимит: `systemd-analyze cat-config systemd/journald.conf` — итоговая конфигурация со всеми drop-in'ами.
   В `/etc/systemd/journald.conf.d/90-retention.conf` — `SystemMaxUse=8G`.
3. Кто больше всех пишет: `journalctl --since today -o json | jq -r ._SYSTEMD_UNIT | sort | uniq -c | sort -rn | head`.

## Решение
```bash
cat > /etc/systemd/journald.conf.d/90-retention.conf <<'EOF'
[Journal]
Storage=persistent
SystemMaxUse=200M
SystemKeepFree=1G
EOF
systemctl restart systemd-journald
journalctl --vacuum-size=200M          # удалить старые архивные файлы прямо сейчас
journalctl --disk-usage
```
Другие способы чистки: `--vacuum-time=7d`, `--vacuum-files=5`. Активный файл журнала vacuum не трогает:
`journalctl --rotate` закрывает его, и после этого его тоже можно почистить.

## Доп. вопросы на собеседовании
- Где хранится журнал: `/run/log/journal` vs `/var/log/journal`? Что значит `Storage=auto`?
- Как смотреть логи с прошлой загрузки? (`journalctl -b -1`) Почему их может не быть?
- Как journald связан с rsyslog и `/var/log/syslog`? (`ForwardToSyslog`)
- Что такое rate limiting в journald (`RateLimitBurst`) и почему пропадают сообщения у болтливых сервисов?
- Как отправлять логи в центральное хранилище? (rsyslog, Vector, Fluent Bit, Promtail → Loki)
