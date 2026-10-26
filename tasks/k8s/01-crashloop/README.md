# k8s-01 · Pod в CrashLoopBackOff

**Уровень:** Junior/Middle · **Тема:** Kubernetes / поды · **Время:** ~20 мин

## Легенда
В namespace `k01` задеплоили API (`deployment/api`). Код сервиса лежит в ConfigMap
`api-code`, контейнер запускает `python3 /app/server.py`. Сервис отвечает 200 на `/health`
(порт 8080). Под постоянно перезапускается.

```bash
kubectl -n k01 get pods
```

## Задача
Сделай так, чтобы под стабильно работал и был Ready.

## Ограничения
- Код в ConfigMap `api-code` не менять: он рабочий.
- Не удалять пробы (liveness/readiness) — они нужны.

## Критерии готовности (что проверяет check)
- `deployment/api` доступен (rollout завершён), под Ready
- счётчик рестартов не растёт 20 секунд
- ConfigMap `api-code` не изменён, liveness- и readiness-пробы на месте

> Теория по теме — [THEORY.md](THEORY.md) (`sudo ./trainer.sh theory k8s-01`).
> Не читай `break.sh` и `check.sh` — там спойлеры.
