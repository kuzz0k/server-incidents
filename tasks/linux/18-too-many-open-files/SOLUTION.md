# linux-18 · Разбор

## Шаги диагностики
1. `journalctl -u chat-server -n 20` → `cannot open connection #125 of 300: [Errno 24] Too many open files`.
2. Errno 24 = EMFILE: процесс упёрся в лимит открытых дескрипторов (`RLIMIT_NOFILE`).
3. Какой лимит у процесса реально: `cat /proc/<PID>/limits | grep 'open files'` (если успел запуститься)
   или `systemctl show -p LimitNOFILE chat-server` → 128.
4. Почему не помог `limits.d`: `pam_limits` применяется только к PAM-сессиям (ssh, login, su).
   Сервисы запускает systemd, и для них лимит задаётся в юните (`LimitNOFILE=`) или глобально в `system.conf` (`DefaultLimitNOFILE=`).
5. `systemctl cat chat-server` → `LimitNOFILE=128`.

## Решение
```bash
systemctl edit chat-server
#   [Service]
#   LimitNOFILE=65536
systemctl daemon-reload            # edit делает сам, но не повредит
systemctl restart chat-server
grep 'open files' /proc/$(systemctl show -p MainPID --value chat-server)/limits
```

## Как не допустить снова
- Поднимать лимиты для сервисов в юнитах и проверять через `/proc/PID/limits`.
- Мониторинг числа открытых fd (`ls /proc/PID/fd | wc -l`, `process_open_fds` в метриках).

## Доп. вопросы на собеседовании
- Чем soft limit отличается от hard? Как посмотреть и поменять? (`ulimit -Sn`/`-Hn`, `prlimit`)
- Что такое `fs.file-max` и `fs.nr_open`, чем отличаются от `ulimit -n`?
- Как поменять лимит уже запущенного процесса без рестарта? (`prlimit --pid`)
- Почему сокеты тоже считаются файловыми дескрипторами?
- Как найти процесс, у которого больше всего открытых файлов?
- Какие ещё лимиты бывают в systemd? (`LimitNPROC`, `TasksMax`, `MemoryMax`)
