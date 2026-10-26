# linux-19 · Разбор

## Шаги диагностики
1. `systemctl status imagecache` → `Main process exited, code=killed, status=9/KILL` и `Failed with result 'oom-kill'`.
2. `journalctl -k | grep -i oom` (или `dmesg -T | grep -i oom`) → `Memory cgroup out of memory: Killed process ... (python3)`.
   Значит, процесс убил ядерный OOM killer внутри cgroup сервиса, а не системный OOM на весь сервер.
3. `systemctl show imagecache -p MemoryMax,MemoryCurrent,MemoryPeak` → лимит 64M.
4. `cat /etc/imagecache.conf` → `CACHE_MB=128`: кеш не помещается в лимит.

## Решение
```bash
sed -i 's/^CACHE_MB=.*/CACHE_MB=32/' /etc/imagecache.conf
systemctl restart imagecache
systemctl show imagecache -p MemoryCurrent
```

## Как не допустить снова
- Размер кешей/heap задавать с учётом лимита cgroup (для JVM — `-XX:MaxRAMPercentage`).
- Алерт по `oom_kill` событиям (`node_vmstat_oom_kill`, `memory.events` cgroup).

## Доп. вопросы на собеседовании
- Как OOM killer выбирает жертву? Что такое `oom_score` и `oom_score_adj`?
- Чем cgroup OOM отличается от системного OOM?
- Что значат RSS, VSZ, PSS? Почему сумма RSS процессов больше, чем занято памяти?
- Что показывает `free -h`: buff/cache, available? Почему «свободной» памяти мало — это нормально?
- Что такое swap, swappiness? Нужен ли swap на сервере с БД? (см. linux-26)
- Как Kubernetes использует cgroups для `limits.memory`? Что такое OOMKilled в поде?
