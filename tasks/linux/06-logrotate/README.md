# linux-06 · logrotate не ротирует логи

**Уровень:** Middle · **Тема:** Linux / логи · **Время:** ~15 мин

## Легенда
Сервис биллинга `billing-app` пишет лог в `/var/log/billing/billing.log`. Для него
настроен logrotate (`/etc/logrotate.d/billing`), но лог растёт неделями и уже весит
десятки мегабайт, а ротированных файлов нет.

## Задача
Выясни, почему logrotate не ротирует этот лог, и почини конфигурацию.

## Ограничения
- Права на каталог `/var/log/billing` (775, `billing:billing`) менять нельзя: туда
  пишут несколько сервисов из группы `billing`.
- Приложение после ротации должно продолжать писать лог.

## Критерии готовности (что проверяет check)
- `logrotate -d /etc/logrotate.d/billing` проходит без ошибок
- принудительная ротация (`logrotate -f`) создаёт `billing.log.1*`
- после ротации `billing-app` пишет в новый `billing.log`
- права каталога остались 775 `billing:billing`

> Теория по теме — [THEORY.md](THEORY.md) (`sudo ./trainer.sh theory linux-06`).
> Не читай `break.sh` и `check.sh` — там спойлеры.
