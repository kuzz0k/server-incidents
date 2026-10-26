# linux-20 · Разбор

## Шаги диагностики
1. `systemctl status cron`, `journalctl -u cron --since "10 min ago"` — что cron пишет о заданиях.
2. Ничего не пишет: cron **игнорирует файлы в `/etc/cron.d` с точкой в имени** (те же правила, что у run-parts). `db-backup.cron` → `db-backup`.
3. После переименования в журнале cron: `Error: bad username; while reading /etc/cron.d/db-backup`.
   В `/etc/cron.d` и `/etc/crontab` шестое поле — пользователь, в отличие от `crontab -e`.
4. Задание стартует, но лог не пишется: в crontab `%` — спецсимвол (перевод строки / stdin), его надо экранировать `\%`.
5. `ls -l /opt/backup/db-backup.sh` → нет `x`: cron не может его исполнить (`Permission denied` в логе).

## Решение
```bash
mv /etc/cron.d/db-backup.cron /etc/cron.d/db-backup
cat > /etc/cron.d/db-backup <<'EOF'
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
* * * * * root /opt/backup/db-backup.sh > /var/log/db-backup-$(date +\%F).log 2>&1
EOF
chmod 644 /etc/cron.d/db-backup
chmod +x /opt/backup/db-backup.sh
```

## Как не допустить снова
- Отлаживать: сначала руками в окружении, похожем на cron (`env -i /bin/sh -c '...'`).
- Всегда перенаправлять вывод задания в лог, ставить `MAILTO`.
- Для нового — systemd timers: логи в journald, `systemctl list-timers`, зависимости.

## Доп. вопросы на собеседовании
- Чем `/etc/crontab` и `/etc/cron.d/*` отличаются от `crontab -e`?
- Почему скрипт работает руками, но не из cron? (PATH, переменные окружения, рабочий каталог, права)
- Как написать «каждые 15 минут по будням с 9 до 18»? (`*/15 9-18 * * 1-5`)
- Что такое `anacron`, и чем он отличается от cron?
- Как запретить параллельный запуск, если задание работает дольше интервала? (`flock -n`)
- Systemd timer vs cron: плюсы и минусы. Что такое `Persistent=true`?
