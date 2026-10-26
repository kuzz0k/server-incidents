# linux-35 · systemd timer не срабатывает

**Уровень:** Junior/Middle · **Тема:** Linux / systemd · **Время:** ~15 мин

## Легенда
Вместо cron решили использовать systemd timer: `healthcheck.timer` должен **каждую минуту**
запускать `healthcheck.service`, а тот — скрипт `/usr/local/bin/healthcheck.sh`, который пишет
`STATUS: OK` в `/var/log/healthcheck.log`. Лог пустой уже сутки.

## Задача
Почини таймер, чтобы проверка выполнялась каждую минуту и после перезагрузки тоже.

## Ограничения
- Только systemd timer, без cron.

## Критерии готовности (что проверяет check)
- `healthcheck.timer` активен и включён
- расписание таймера срабатывает не реже раза в минуту
- в течение ~90 секунд в логе появляется новая строка `STATUS: OK`

> Теория по теме — [THEORY.md](THEORY.md) (`sudo ./trainer.sh theory linux-35`).
> Не читай `break.sh` и `check.sh` — там спойлеры.
