# linux-49 · Разбор

## Шаги диагностики
1. `journalctl -u job-runner -n 20` → `RuntimeError: can't start new thread` (в C — `pthread_create: Resource temporarily unavailable`, EAGAIN; в shell — `fork: retry: Resource temporarily unavailable`).
2. Потоки в Linux — тоже задачи (tasks). Ограничивают их несколько механизмов:
   - `ulimit -u` / `RLIMIT_NPROC` — на пользователя (тут в порядке);
   - `kernel.pid_max`, `kernel.threads-max` — на всю систему;
   - **cgroup `pids.max`** — на сервис: `systemctl show job-runner -p TasksMax,TasksCurrent`.
3. `systemctl cat job-runner` → `TasksMax=16`.

## Решение
```bash
systemctl edit job-runner
#   [Service]
#   TasksMax=256
systemctl restart job-runner
systemctl show job-runner -p TasksCurrent,TasksMax
```
Значение по умолчанию задаёт `DefaultTasksMax=` в `/etc/systemd/system.conf` (15% от `pid_max`). Похожую ошибку дают поды в Kubernetes с `podPidsLimit` и контейнеры с `docker run --pids-limit`.

## Доп. вопросы на собеседовании
- Чем процесс отличается от потока с точки зрения ядра? Что такое TID?
- Какие лимиты на количество процессов и потоков бывают и где их смотреть?
- Что такое fork bomb и как от неё защищает cgroup pids?
- Как посмотреть потоки процесса? (`ps -L`, `top -H`, `/proc/PID/task`)
- Почему `ulimit` в shell не влияет на сервис systemd?
