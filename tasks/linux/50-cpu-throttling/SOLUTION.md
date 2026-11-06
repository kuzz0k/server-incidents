# linux-50 · Разбор

## Шаги диагностики
1. `time curl http://127.0.0.1:8050/price` → ~5 с. В `top` во время запроса процесс ест ~4% CPU и не больше.
2. Похоже на внешнее ограничение. `systemctl show pricing-api -p CPUQuotaPerSecUSec` → `40ms` (4% одного ядра).
   `systemd-cgtop` показывает CPU по сервисам.
3. Доказательство троттлинга — статистика cgroup:
   ```bash
   cat /sys/fs/cgroup/system.slice/pricing-api.service/cpu.stat   # nr_throttled, throttled_usec растут
   cat /sys/fs/cgroup/system.slice/pricing-api.service/cpu.max    # 4000 100000
   ```
   Задаче нужно 0,2 с CPU, а в каждые 100 мс ей дают только 4 мс, поэтому 0,2 с растягиваются в ~5 с.

## Решение
```bash
systemctl edit pricing-api
#   [Service]
#   CPUQuota=50%
systemctl daemon-reload            # edit делает сам
time curl http://127.0.0.1:8050/price
```
CPUQuota применяется на лету, рестарт не нужен.

## Доп. вопросы на собеседовании
- Чем `CPUQuota` (жёсткий потолок, cpu.max) отличается от `CPUWeight` (доля при конкуренции, cpu.weight)?
- Что такое CFS bandwidth throttling и почему он бьёт по latency даже при свободном CPU?
- Как это выглядит в Kubernetes? (`limits.cpu` → cpu.max; почему многие не ставят CPU limits)
- Чем 100% CPU в `top` отличается от 100% в cgroup? Как считаются несколько ядер?
- Где посмотреть статистику троттлинга? (`cpu.stat`, метрика `container_cpu_cfs_throttled_periods_total`)
