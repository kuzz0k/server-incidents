# linux-25 · Маршрутизация между сетями

**Уровень:** Middle · **Тема:** Linux / сеть, маршрутизация · **Время:** ~25 мин

## Легенда
Стенд из трёх «машин», собранных в network namespaces:

```
 tr-client                tr-router                  tr-backend
 c0 10.25.0.2/24 ─────── r0 10.25.0.1/24
                          r1 10.26.0.1/24 ───────── b0 10.26.0.2/24
                                                     HTTP :8080
```

Клиент должен ходить на backend через роутер, но `curl` из клиента не работает.
Команды внутри «машины» выполняются так:
```bash
ip netns exec tr-client ip addr
ip netns exec tr-router sysctl net.ipv4.ip_forward
ip netns exec tr-client curl -s --max-time 3 http://10.26.0.2:8080/
```

## Задача
Добейся, чтобы `curl http://10.26.0.2:8080/` из `tr-client` отвечал `backend ok`.
Проблем несколько, ищи по слоям: интерфейс → адрес → маршрут → форвардинг → обратный маршрут.

## Ограничения
- Адресация (подсети и IP) должна остаться такой, как на схеме.
- Без NAT: backend должен видеть реальный адрес клиента.

## Критерии готовности (что проверяет check)
- `ip netns exec tr-client curl http://10.26.0.2:8080/` → `backend ok`
- адрес клиента — `10.25.0.2/24`
- в `tr-router` нет NAT-правил (MASQUERADE/SNAT)

> Теория по теме — [THEORY.md](THEORY.md) (`sudo ./trainer.sh theory linux-25`).
> Не читай `break.sh` и `check.sh` — там спойлеры.
