# k8s-04 · Разбор

## Шаги диагностики
1. `kubectl -n k04 get pods` → `Pending`. `kubectl -n k04 describe pod <pod>` → Events от scheduler:
   `0/1 nodes are available: pod has unbound immediate PersistentVolumeClaims` и/или `Insufficient cpu, Insufficient memory`.
2. `kubectl -n k04 get pvc` → `Pending`; `describe pvc worker-data` → `storageclass.storage.k8s.io "fast-ssd" not found`.
   `kubectl get storageclass` → в k3s есть только `local-path (default)`.
3. `kubectl describe node | grep -A8 Allocatable` — у ноды 2–4 CPU, а под просит 8 CPU и 16Gi.

## Решение
`storageClassName` у PVC неизменяем — PVC придётся пересоздать. Пока под ссылается на PVC, его не удалить (finalizer `pvc-protection`):
```bash
kubectl -n k04 scale deploy worker --replicas=0
kubectl -n k04 delete pvc worker-data
kubectl -n k04 apply -f - <<'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: worker-data, namespace: k04}
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: local-path
  resources: {requests: {storage: 1Gi}}
EOF
kubectl -n k04 set resources deploy worker --requests=cpu=100m,memory=128Mi --limits=memory=256Mi
kubectl -n k04 scale deploy worker --replicas=1
kubectl -n k04 get pods,pvc -w
```
`local-path` имеет `volumeBindingMode: WaitForFirstConsumer`: PVC станет Bound только после того, как под будет запланирован.

## Как не допустить снова
- Значения requests/limits и storageClass — параметры Helm-чарта под каждое окружение.
- `LimitRange`/`ResourceQuota` в namespace, чтобы ловить заведомо нереальные requests.

## Доп. вопросы на собеседовании
- Чем requests отличаются от limits? Что такое QoS-классы (Guaranteed, Burstable, BestEffort)?
- Что будет при превышении лимита CPU и при превышении лимита памяти?
- Как scheduler выбирает ноду? (filter → score; taints/tolerations, nodeSelector, affinity)
- PV, PVC, StorageClass, provisioner — как связаны? Что такое `volumeBindingMode`, `reclaimPolicy`?
- Почему под может быть Pending, даже если ресурсов хватает? (taints, PVC в другой зоне, nodeSelector)
