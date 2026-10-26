# k8s-04 · Pod завис в Pending

**Уровень:** Middle · **Тема:** Kubernetes / планирование, хранилище · **Время:** ~20 мин

## Легенда
В namespace `k04` развернули фоновый `deployment/worker` с диском `pvc/worker-data`.
Манифест скопировали с большого прод-кластера. Под уже полчаса в `Pending`.
Воркеру реально хватает 100m CPU и 128Mi памяти.

## Задача
Запусти воркер на этом кластере.

## Ограничения
- Воркер должен работать с постоянным диском `worker-data` (1Gi), монтируемым в `/data`.
- Requests не больше 500m CPU и 512Mi памяти.

## Критерии готовности (что проверяет check)
- под `worker` Running и Ready
- `pvc/worker-data` в состоянии Bound, storageClass существует в кластере
- requests: CPU ≤ 500m, память ≤ 512Mi

> Теория по теме — [THEORY.md](THEORY.md) (`sudo ./trainer.sh theory k8s-04`).
> Не читай `break.sh` и `check.sh` — там спойлеры.
