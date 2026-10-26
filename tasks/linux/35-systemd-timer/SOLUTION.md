# linux-35 · Разбор

## Шаги диагностики
1. `systemctl list-timers --all | grep health` — таймер `inactive`, следующего запуска нет.
2. `systemctl cat healthcheck.timer` — три проблемы:
   - `Unit=health-check.service`: такого сервиса нет (по умолчанию таймер запускает одноимённый `.service`, и `Unit=` вообще не нужен);
   - `OnCalendar=*-*-* 00:*:00` — это «каждую минуту, но только с 00:00 до 00:59». Проверка: `systemd-analyze calendar '*-*-* 00:*:00' --iterations=3`;
   - таймер не включён (`enable`) и не запущен.
3. Запустить сервис вручную: `systemctl start healthcheck.service` → `status=203/EXEC` / `Permission denied`: у скрипта нет права на исполнение.

## Решение
```bash
chmod +x /usr/local/bin/healthcheck.sh
systemctl edit --full healthcheck.timer
#   [Timer]
#   OnCalendar=*-*-* *:*:00        # или OnCalendar=minutely
#   Persistent=true
#   (строку Unit= удалить или исправить на healthcheck.service)
systemctl daemon-reload
systemctl enable --now healthcheck.timer
systemctl list-timers healthcheck.timer
journalctl -u healthcheck.service -f
```

## Доп. вопросы на собеседовании
- systemd timer vs cron: плюсы и минусы? (логи в journald, зависимости, `Persistent=`, `RandomizedDelaySec=`, нет почты)
- Чем `OnCalendar=` отличается от `OnBootSec=` и `OnUnitActiveSec=`?
- Что делает `Persistent=true`?
- Как проверить выражение календаря? (`systemd-analyze calendar`)
- Почему сервис для таймера обычно `Type=oneshot`?
