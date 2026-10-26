# linux-16 · Разбор

## Шаги диагностики
1. `uptime` — load average около 1 (на одно ядро).
2. `top` (сортировка по CPU — `P`) или `ps -eo pid,user,%cpu,cmd --sort=-%cpu | head` — процесс `python3 .../thumbnailer.py`, ~100% CPU.
3. `systemctl status <PID>` → `thumbnailer.service`; `systemctl cat thumbnailer` — какой конфиг он читает.
4. Что делает процесс:
   - `strace -p <PID> -c` (Ctrl+C через пару секунд) — тысячи `openat`/`getdents64` в секунду, ни одного `sleep`;
   - `py-spy dump`, `perf top` — для других языков.
5. `cat /etc/thumbnailer.conf` → `POLL_INTERVAL=0`: сервис опрашивает каталог очереди без паузы (busy loop).

## Решение
```bash
sed -i 's/^POLL_INTERVAL=.*/POLL_INTERVAL=2/' /etc/thumbnailer.conf
systemctl restart thumbnailer
top -p "$(systemctl show -p MainPID --value thumbnailer)"
```

## Как не допустить снова
- Валидировать конфиг: минимальные значения интервалов.
- Для очередей использовать события (inotify, брокер сообщений) вместо поллинга.
- Алерт на CPU по сервису (cgroup-метрики, `systemd-cgtop`).

## Доп. вопросы на собеседовании
- Что такое load average? Почему он может быть высоким при свободном CPU? (процессы в D-state, I/O)
- Что значат `us`, `sy`, `wa`, `st`, `si` в top?
- Как посмотреть потребление CPU по сервисам? (`systemd-cgtop`)
- Какие сигналы знаешь? Чем `SIGTERM` отличается от `SIGKILL`, зачем `SIGHUP`?
- Как ограничить CPU сервиса средствами systemd и когда это уместно?
- Чем полезен `strace`, а когда лучше `perf`?
