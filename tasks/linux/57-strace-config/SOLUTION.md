# linux-57 · Разбор

## Шаги диагностики
1. `systemctl cat geo-api` — какая команда запускается.
2. Запустить её под strace и посмотреть, какие файлы программа пытается открыть:
   ```bash
   strace -f -e trace=openat,open,stat,newfstatat,access /usr/bin/python3 /opt/geo-api/geo-api.py 2>&1 | grep -E 'geo|conf'
   ```
   → `openat(AT_FDCWD, "/etc/geo/geo-api.conf", O_RDONLY…) = -1 ENOENT (No such file or directory)`.
   Можно и на работающем процессе: `strace -f -p <PID>`. Для упавшего сервиса удобнее запустить руками от того же пользователя (`sudo -u …`).
3. Вендор поменял путь в новой версии, а документацию не обновил.

## Решение
```bash
mkdir -p /etc/geo
cp /etc/geo-api.conf /etc/geo/geo-api.conf      # или симлинк, если старый путь нужен другим
systemctl restart geo-api
```

## Доп. вопросы на собеседовании
- Что показывает strace? Какие флаги часто нужны? (`-f`, `-e trace=`, `-p`, `-s`, `-c`, `-o`, `-T`)
- Чем strace опасен на проде? Чем его заменить? (сильное замедление; `perf trace`, eBPF: `opensnoop`, `execsnoop`)
- Как узнать, какие файлы открыты процессом сейчас? (`ls -l /proc/PID/fd`, `lsof -p`)
- Что такое `ltrace` и чем он отличается от strace?
- Как найти, какой пакет должен был положить файл? (`dpkg -S`)
