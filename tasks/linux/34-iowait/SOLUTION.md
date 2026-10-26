# linux-34 · Разбор

## Шаги диагностики
1. `uptime` / `cat /proc/loadavg` → LA ~1–2, `nproc` → сколько ядер.
2. `top` → `%Cpu: ... id 9x, wa NN` — CPU простаивает, но высокий **iowait**.
   Load average в Linux считает не только процессы в очереди на CPU (R), но и в непрерываемом ожидании I/O (**D**).
3. Кто в D-state: `ps -eo pid,stat,wchan:20,cmd | awk '$2 ~ /D/'`.
4. Какой диск и насколько загружен: `iostat -xz 1` (`%util`, `await`), `vmstat 1` (колонки `b` и `wa`).
5. Какой процесс пишет: `pidstat -d 1`, `iotop -o`, или `cat /proc/<PID>/io`.
6. `systemctl status <PID>` → `search-reindex.service`.

## Решение
```bash
echo "unit=search-reindex.service" > /root/answers/linux-34.txt
systemctl edit search-reindex
#   [Service]
#   IOSchedulingClass=idle
#   Nice=19
systemctl restart search-reindex
ionice -p "$(systemctl show -p MainPID --value search-reindex)"   # idle
```
Разово, без рестарта: `ionice -c3 -p <PID>` и `renice 19 -p <PID>`, но это не переживёт перезапуск.

## Как не допустить снова
- Тяжёлые фоновые задачи (бэкапы, индексация) — с `IOSchedulingClass=idle`/`Nice=` или лимитами `IOWeight=`, `IOReadBandwidthMax=`.
- Мониторинг iowait и `%util` дисков, а не только CPU.

## Доп. вопросы на собеседовании
- Почему LA бывает высоким при свободном CPU? Что такое D-state и почему его нельзя убить?
- Что такое iowait? Это «занятый» или «свободный» CPU?
- Как читать `iostat -x`: `r/s`, `w/s`, `await`, `%util`? Почему 100% util у SSD/NVMe не всегда предел?
- Чем `nice` отличается от `ionice`? Какие классы ionice бывают? Работают ли они с любым I/O-планировщиком?
- Как ограничить I/O сервиса средствами cgroups v2?
