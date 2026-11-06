# linux-47 · Permission denied у скрипта с правами 755

**Уровень:** Junior · **Тема:** Linux / монтирование, права · **Время:** ~15 мин

## Легенда
Сервис `cache-rotate` (одноразовый, запускается `systemctl start cache-rotate`) вызывает скрипт
`/srv/tools/rotate-cache.sh`. Сервис падает с `Permission denied`, хотя у скрипта права
`-rwxr-xr-x root root`, и запуск от root тоже даёт `Permission denied`.

## Задача
Добейся, чтобы `systemctl start cache-rotate` отрабатывал успешно.

## Ограничения
- Скрипт должен остаться в `/srv/tools`: так его раскатывают.
- Безопасники требуют, чтобы `/srv/tools` был смонтирован с `noexec`: не снимай эту опцию ни сейчас, ни в fstab.

## Критерии готовности (что проверяет check)
- `systemctl start cache-rotate` завершается успешно, скрипт отработал (пишет отметку в `/var/log/cache-rotate.log`)
- `/srv/tools` по-прежнему смонтирован с `noexec`, и в fstab тоже `noexec`
- скрипт лежит в `/srv/tools`

> Теория по теме — [THEORY.md](THEORY.md) (`sudo ./trainer.sh theory linux-47`).
> Не читай `break.sh` и `check.sh` — там спойлеры.
