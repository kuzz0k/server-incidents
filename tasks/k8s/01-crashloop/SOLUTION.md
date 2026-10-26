# k8s-01 · Разбор

## Шаги диагностики
1. `kubectl -n k01 get pods` → `CrashLoopBackOff`, растёт RESTARTS.
2. `kubectl -n k01 logs deploy/api` (или `--previous` для упавшего контейнера) → `can't open file '/app/server.py'`.
3. `kubectl -n k01 describe pod <pod>` / `kubectl -n k01 get deploy api -o yaml` — ConfigMap смонтирован в `/opt/app`, а команда ищет `/app/server.py`.
4. После исправления под стартует и становится Ready, но через ~10 секунд снова рестарт.
   `kubectl -n k01 describe pod` → Events: `Liveness probe failed: HTTP probe failed with statuscode: 404`, `Container api failed liveness probe, will be restarted`.
   Liveness смотрит на `/healthz`, а сервис отвечает на `/health`.

## Решение
```bash
kubectl -n k01 edit deploy api
#   volumeMounts[0].mountPath: /app
#   livenessProbe.httpGet.path: /health
kubectl -n k01 rollout status deploy/api
kubectl -n k01 get pods -w
```
Или патчем:
```bash
kubectl -n k01 patch deploy api --type=json -p='[
 {"op":"replace","path":"/spec/template/spec/containers/0/volumeMounts/0/mountPath","value":"/app"},
 {"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/httpGet/path","value":"/health"}]'
```

## Как не допустить снова
- Манифесты в git, проверка в CI (`kubeconform`), деплой через Helm/Argo CD с откатом при неудачном rollout.
- Для медленного старта — `startupProbe`, а не огромный `initialDelaySeconds` у liveness.

## Доп. вопросы на собеседовании
- Чем liveness отличается от readiness и startup пробы? Что будет при падении каждой?
- Что значит CrashLoopBackOff и как растёт задержка между рестартами?
- Как посмотреть логи предыдущего (упавшего) контейнера? (`logs --previous`)
- Статусы пода: Pending, ContainerCreating, Running, Completed, Error, OOMKilled, CreateContainerConfigError — откуда каждый?
- Как дебажить под, в котором нет shell? (`kubectl debug -it --image=busybox --target=...`)
- Почему liveness-проба не должна проверять внешние зависимости (БД)?
