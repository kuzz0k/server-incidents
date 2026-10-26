# monitoring-01 · Prometheus не стартует и не видит цели

**Уровень:** Middle · **Тема:** мониторинг / Prometheus · **Время:** ~25 мин

## Легенда
На сервере поднят мониторинг: Prometheus (`:9090`), node_exporter и приложение `metrics-app`
(порт **8301**, метрики на `/metrics`). Коллега добавил алерт на заполнение дисков и
поправил конфиг. Теперь Prometheus лежит, а когда работал, часть целей была `DOWN`.

## Задача
Подними Prometheus так, чтобы все цели (`prometheus`, `node`, `app`) были `UP` и алерт
`HighDiskUsage` загружался.

## Ограничения
- Задания (`job_name`) и алерт не удалять: мониторинг нужен целиком.
- node_exporter и приложение не трогать.

## Критерии готовности (что проверяет check)
- `promtool check config /etc/prometheus/prometheus.yml` без ошибок, Prometheus активен
- в `/api/v1/targets` у заданий `prometheus`, `node`, `app` все цели `up`
- правило `HighDiskUsage` загружено (`/api/v1/rules`)

> Теория по теме — [THEORY.md](THEORY.md) (`sudo ./trainer.sh theory monitoring-01`).
> Не читай `break.sh` и `check.sh` — там спойлеры.
