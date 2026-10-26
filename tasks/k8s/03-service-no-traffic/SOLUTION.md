# k8s-03 · Разбор

Идём по цепочке Ingress → Service → Endpoints → Pod.

## Шаги диагностики
1. Поды живы: `kubectl -n k03 get pods -o wide --show-labels` → метка `app=backend-api`.
2. `kubectl -n k03 get endpoints backend` (или `endpointslices`) → `<none>`: Service никого не выбрал.
   `kubectl -n k03 get svc backend -o yaml` → `selector: app: backend` — не совпадает с метками подов.
3. После исправления selector endpoints появились, но с портом 8080. В поде nginx слушает 80:
   `kubectl -n k03 get pod <pod> -o jsonpath='{.spec.containers[0].ports}'`. `targetPort` должен указывать на порт контейнера.
   Проверка изнутри кластера: `kubectl -n k03 run t --rm -it --image=busybox:1.36 -- wget -qO- backend`.
4. Ingress: `kubectl -n k03 describe ingress backend` → backend `backend:8080`, а у Service порт 80.
   Логи traefik: `kubectl -n kube-system logs deploy/traefik | grep k03`.

## Решение
```bash
kubectl -n k03 patch svc backend --type=json -p='[
 {"op":"replace","path":"/spec/selector","value":{"app":"backend-api"}},
 {"op":"replace","path":"/spec/ports/0/targetPort","value":80}]'
kubectl -n k03 patch ingress backend --type=json -p='[
 {"op":"replace","path":"/spec/rules/0/http/paths/0/backend/service/port/number","value":80}]'
kubectl -n k03 get endpoints backend
curl -H 'Host: backend.trainer.local' http://<IP>/
```

## Как не допустить снова
- Именованные порты: `containerPort` с `name: http`, в Service `targetPort: http`, в Ingress `port.name: http`.
- Метки и селекторы из одного шаблона (Helm `selectorLabels`).

## Доп. вопросы на собеседовании
- Типы Service: ClusterIP, NodePort, LoadBalancer, ExternalName, headless. Когда какой?
- Чем `port`, `targetPort` и `nodePort` отличаются?
- Как kube-proxy реализует Service? (iptables/IPVS, eBPF в Cilium)
- Как работает DNS внутри кластера? (`backend.k03.svc.cluster.local`, CoreDNS)
- Ingress vs Gateway API. Что такое IngressClass?
- Как ограничить трафик между подами? (NetworkPolicy)
