# k8s-06 · Разбор

## Шаги диагностики
1. Изнутри пода: `kubectl -n k06-app exec deploy/frontend -- sh -c 'echo $DB_URL; nslookup backend-db'`.
   Короткое имя `backend-db` резолвится только в **своём** namespace (`search k06-app.svc.cluster.local ...` в `/etc/resolv.conf` пода),
   поэтому получаем NXDOMAIN. Нужно `backend-db.k06-db` или FQDN `backend-db.k06-db.svc.cluster.local`.
2. С правильным именем wget висит по таймауту, значит режет NetworkPolicy:
   `kubectl -n k06-db get networkpolicy -o yaml`. Разрешающая политика пускает трафик только если
   **одновременно** (один элемент `from`) namespace имеет метку `team=shop` и под имеет метку `role=frontend`.
3. `kubectl get ns k06-app --show-labels` — метки `team=shop` нет; `kubectl -n k06-app get pods --show-labels` — нет `role=frontend`.

## Решение
```bash
kubectl label namespace k06-app team=shop
kubectl -n k06-app patch deploy frontend --type=merge -p \
  '{"spec":{"template":{"metadata":{"labels":{"role":"frontend"}}}}}'
kubectl -n k06-app set env deploy/frontend DB_URL=http://backend-db.k06-db.svc.cluster.local/
kubectl -n k06-app rollout status deploy/frontend
kubectl -n k06-app logs deploy/frontend --tail=3
```

## Важно про NetworkPolicy
- Два селектора в **одном** элементе `from` объединяются через И, а в **разных** элементах через ИЛИ. Частая ошибка с открытием доступа всем.
- Политики работают, только если CNI их поддерживает (Calico, Cilium, kube-router в k3s). Во flannel без контроллера они молча игнорируются.
- Не забывай про egress: если есть default-deny egress, нужен явный доступ к DNS (UDP/TCP 53 к kube-dns).

## Доп. вопросы на собеседовании
- Как устроен DNS в кластере? Что такое `search` и `ndots:5` в resolv.conf пода и почему это бывает медленно?
- Как работает default deny и зачем он нужен?
- Как проверить связность между подами? (`kubectl exec ... wget/nc`, `kubectl debug`, netshoot)
- Чем Service ClusterIP отличается от headless? Как резолвится headless?
- Что такое CNI и какие плагины знаешь?
