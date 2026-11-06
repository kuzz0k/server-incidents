# linux-51 · Разбор

```bash
journalctl -u payment-gw -p err --no-pager                 # только приоритет err и выше
journalctl -u payment-gw -p err -o short-iso --no-pager    # с точным временем
journalctl -u payment-gw | grep -c error                   # «шум»: grep по слову находит не то
systemctl show payment-gw -p NRestarts                     # счётчик автоматических рестартов
journalctl -u payment-gw | grep -E 'Main process exited|Scheduled restart'
```
Приоритет сообщения сервис задаёт префиксом `<3>` в начале строки (`SyslogLevelPrefix=`) или через `sd_journal_print`/syslog.

Полезные фильтры: `--since "10 min ago"`, `--until`, `-b` (текущая загрузка), `-o json`/`json-pretty`,
`_PID=`, `_SYSTEMD_UNIT=`, `-k` (ядро), `-f` (follow), `--grep`, `-r` (в обратном порядке).

## Доп. вопросы на собеседовании
- Какие уровни приоритета syslog знаешь? (emerg, alert, crit, err, warning, notice, info, debug)
- Как посмотреть логи сервиса за прошлую загрузку? Почему их может не быть?
- Как вывести логи в JSON и отфильтровать по полю?
- Как journald связан с rsyslog? Где лежит журнал на диске?
- Как собирать логи со всех серверов в одно место?
