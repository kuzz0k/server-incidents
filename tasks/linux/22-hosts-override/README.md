# linux-22 · Имя резолвится не туда

**Уровень:** Junior · **Тема:** Linux / сеть, резолвинг · **Время:** ~10 мин

## Легенда
Платёжный API переехал на новый адрес. Сервисы на этом сервере ходят в него по имени
`api.payments.internal` (порт 8022). После переезда все запросы получают
`Connection refused`, хотя API работает: команда платежей клянётся, что на их стороне всё в порядке.
`dig api.payments.internal` ничего не находит — это внутреннее имя, в DNS его нет.

## Задача
Почини обращение к API по имени: `curl http://api.payments.internal:8022/` должен
отвечать `payments-api ok`.

## Ограничения
- Сам API не трогать (он слушает свой новый адрес).

## Критерии готовности (что проверяет check)
- `getent hosts api.payments.internal` возвращает ровно один адрес — новый
- `curl http://api.payments.internal:8022/` → `payments-api ok`

> Теория по теме — [THEORY.md](THEORY.md) (`sudo ./trainer.sh theory linux-22`).
> Не читай `break.sh` и `check.sh` — там спойлеры.
