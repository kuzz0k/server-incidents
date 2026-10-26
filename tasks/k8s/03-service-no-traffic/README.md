# k8s-03 · Service и Ingress не пропускают трафик

**Уровень:** Middle · **Тема:** Kubernetes / сеть · **Время:** ~25 мин

## Легенда
В namespace `k03` есть `deployment/backend` (nginx со страницей `backend ok`), `service/backend`
и `ingress/backend` для хоста `backend.trainer.local`. Поды Running и Ready, но через
Ingress сайт не открывается.

Проверка (traefik слушает 80 порт сервера):
```bash
curl -H 'Host: backend.trainer.local' http://$(hostname -I | awk '{print $1}')/
```

## Задача
Добейся, чтобы запрос выше возвращал `backend ok`.

## Ограничения
- Pod'ы и образ не трогать: приложение рабочее, проблема в маршрутизации трафика к нему.

## Критерии готовности (что проверяет check)
- у `service/backend` есть endpoints
- `curl -H 'Host: backend.trainer.local' http://<IP>/` → `backend ok`

> Теория по теме — [THEORY.md](THEORY.md) (`sudo ./trainer.sh theory k8s-03`).
> Не читай `break.sh` и `check.sh` — там спойлеры.
