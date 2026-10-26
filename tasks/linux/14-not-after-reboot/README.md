# linux-14 · Сервис не поднялся после ребута

**Уровень:** Junior · **Тема:** Linux / systemd · **Время:** ~10 мин

## Легенда
После планового ребута не поднялся сервис уведомлений `notifier`. Неделю назад его
запустили через `systemctl start` и всё работало. Попытка `systemctl enable notifier`
выдаёт странное предупреждение.

## Задача
Подними `notifier` и сделай так, чтобы он стартовал при каждой загрузке.

## Ограничения
- Не через cron `@reboot` и не через `rc.local`: только средствами systemd.

## Критерии готовности (что проверяет check)
- `notifier` активен, `curl http://127.0.0.1:8014/health` → 200
- `multi-user.target` «хочет» `notifier` (`systemctl show -p WantedBy notifier`)
- `systemctl is-enabled notifier` → `enabled`

> Теория по теме — [THEORY.md](THEORY.md) (`sudo ./trainer.sh theory linux-14`).
> Не читай `break.sh` и `check.sh` — там спойлеры.
