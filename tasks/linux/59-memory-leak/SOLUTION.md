# linux-59 · Разбор

## Шаги диагностики
1. `free -h` / `vmstat 1` — `available` уменьшается.
2. Кто растёт:
   - `ps -eo pid,user,rss,vsz,cmd --sort=-rss | head` — RSS процессов;
   - `systemd-cgtop -m` — память по cgroup/сервисам (видно сразу юнит);
   - `top`, затем `M` (сортировка по памяти).
   Повтори через 10–20 секунд: утечка — это рост, а не просто большой RSS.
3. `systemctl status <PID>` → `cache-warmer.service`. `systemctl show cache-warmer -p MemoryCurrent`.

## Решение
```bash
echo "unit=cache-warmer.service" > /root/answers/linux-59.txt
systemctl edit cache-warmer
#   [Service]
#   MemoryHigh=250M        # мягкий порог: ядро начинает поджимать память (reclaim, троттлинг)
#   MemoryMax=300M         # жёсткий: при превышении сработает OOM killer внутри cgroup
#   Restart=on-failure
systemctl restart cache-warmer
watch -n2 'systemctl show cache-warmer -p MemoryCurrent,NRestarts'
```
Это временная «страховка»: процесс будет убиваться и перезапускаться, но не уронит сервер и соседей.

## Доп. вопросы на собеседовании
- Чем RSS отличается от VSZ и PSS? Почему в `top` сумма RES больше, чем занято памяти?
- Что такое `available` в `free` и почему `free` почти всегда мало?
- `MemoryHigh` vs `MemoryMax` vs `MemorySwapMax`. Что будет при превышении каждого?
- Как найти утечку в конкретном процессе? (`/proc/PID/smaps_rollup`, `pmap -x`, heap-профилировщики)
- Как это устроено в Kubernetes? (`requests`/`limits.memory`, OOMKilled, QoS)
