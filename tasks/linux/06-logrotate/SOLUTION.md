# linux-06 · Разбор

## Шаги диагностики
1. Как запускается logrotate: `systemctl list-timers | grep logrotate` (или `/etc/cron.daily/logrotate`).
2. `journalctl -u logrotate` — ошибки последних запусков.
3. `logrotate -d /etc/logrotate.d/billing` (dry-run) → `skipping ... because parent directory has insecure permissions (It's world writable or writable by group which is not "root")`.
4. `ls -ld /var/log/billing` — 775 `billing:billing`. logrotate защищается от атаки через симлинки и отказывается работать от root в каталоге, куда может писать не-root.

## Решение
Сказать logrotate, от чьего имени ротировать, — директива `su`:
```
/var/log/billing/*.log {
    su billing billing
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 0640 billing billing
}
```
```bash
logrotate -d /etc/logrotate.d/billing        # ошибок нет
logrotate -f /etc/logrotate.d/billing        # принудительно
ls -l /var/log/billing/
```

## Как не допустить снова
- После правки конфигов logrotate всегда прогонять `logrotate -d`.
- Алерт на размер логов/диска.
- Понимать, как приложение переоткрывает лог после ротации: `create` + сигнал в `postrotate` или `copytruncate`.

## Доп. вопросы на собеседовании
- Чем `create` отличается от `copytruncate`? Когда нужен `postrotate`?
- Что такое `delaycompress` и зачем он нужен?
- Где logrotate хранит, когда последний раз ротировал файл? (`/var/lib/logrotate/status`)
- Как ротировать по размеру, а не по времени? (`size`, `maxsize`, `minsize`)
- Как ограничить размер журнала systemd-journald? (`SystemMaxUse=` в journald.conf, `journalctl --vacuum-size`)
