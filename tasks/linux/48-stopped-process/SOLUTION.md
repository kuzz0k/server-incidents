# linux-48 · Разбор

## Шаги диагностики
1. `curl -v --max-time 3 http://127.0.0.1:8048/health` — TCP-соединение устанавливается (ядро принимает его в backlog), а ответа нет.
2. `ps -o pid,stat,wchan,cmd -p $(systemctl show -p MainPID --value quotes-api)` → `STAT` = **`T`**: процесс остановлен сигналом `SIGSTOP` (или `Ctrl+Z`, отладчиком).
   `cat /proc/<PID>/status | grep State` → `T (stopped)`.
3. systemd считает сервис работающим: процесс жив, просто не исполняется. Поэтому нужны внешние health-checks, а не только `is-active`.

## Решение
```bash
kill -CONT <PID>        # продолжить выполнение
curl http://127.0.0.1:8048/health
echo "state=T" > /root/answers/linux-48.txt
```
`systemctl restart` тоже поможет, но потеряет состояние процесса: на проде сначала стоит понять, почему его остановили.

## Доп. вопросы на собеседовании
- Чем `SIGSTOP` отличается от `SIGTSTP`? Можно ли их перехватить?
- Что делают `Ctrl+Z`, `bg`, `fg`, `jobs`?
- Чем T отличается от D и от Z? Что из этого можно «вылечить» сигналом?
- Почему соединение устанавливается, хотя процесс стоит? (backlog `listen()`, его принимает ядро)
- Как systemd может сам обнаружить зависший сервис? (`WatchdogSec=` + `sd_notify`, внешний health-check)
