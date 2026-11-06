# linux-56 · Разбор

## Шаги диагностики
1. `journalctl -u file-sync -n 20` → `Failed to watch /srv/sync-data; upper limit on inotify watches reached!`
   (в других программах — `ENOSPC: System limit for number of file watchers reached` или даже `No space left on device`, хотя место есть).
2. Каждый наблюдаемый каталог — один watch. `find /srv/sync-data -type d | wc -l` → ~3000.
3. `sysctl fs.inotify` → `max_user_watches = 512`. Лимит действует на пользователя (все его процессы вместе).
4. Кто сколько watch'ей держит: `find /proc/*/fdinfo -type f -exec grep -c '^inotify' {} + 2>/dev/null | grep -v ':0$' | sort -t: -k2 -n`.

## Решение
```bash
sysctl -w fs.inotify.max_user_watches=524288
echo 'fs.inotify.max_user_watches=524288' > /etc/sysctl.d/90-inotify.conf
sysctl --system >/dev/null
systemctl reset-failed file-sync; systemctl restart file-sync
```
Каждый watch стоит около 1 КБ памяти ядра, поэтому миллион watch'ей — это около 1 ГБ (на 64-битных системах).

## Доп. вопросы на собеседовании
- Что такое inotify? Чем `max_user_watches` отличается от `max_user_instances` и `max_queued_events`?
- Почему ошибка иногда выглядит как «No space left on device»?
- Какие sysctl ты менял на проде и зачем? (`vm.max_map_count` для Elasticsearch, `net.core.somaxconn`, `fs.file-max`)
- Как применить sysctl без перезагрузки и как сделать постоянным? Порядок чтения `/etc/sysctl.d`?
- Где это бьёт в Kubernetes? (много подов с file watcher на одной ноде, ошибки kubelet/promtail)
