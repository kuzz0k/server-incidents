# k8s-05 · Разбор

## Шаги диагностики
1. `kubectl -n k05 get pods` → `InvalidImageName`. `kubectl -n k05 describe pod` → образ `nginx:` без тега.
2. Посмотреть, что реально рендерит чарт: `helm template hello /opt/trainer-k8s/charts/hello | less` или
   `helm get manifest hello -n k05`. Сравнить с `values.yaml`:
   - шаблон берёт `.Values.image.tag`, а в values ключ `image.version`;
   - шаблон берёт `.Values.replicas`, а в values `replicaCount`. Отсутствующий ключ даёт пустое значение,
     `replicas:` становится `null`, и Kubernetes ставит 1;
   - ConfigMap смонтирован как `index.htm`, а nginx отдаёт `index.html`, поэтому видна стандартная страница nginx.
3. `helm lint` такие ошибки не ловит. Помогают `helm template --debug`, функция `required`
   (`{{ required "image.tag is required" .Values.image.tag }}`) и `values.schema.json`.

## Решение
```bash
cd /opt/trainer-k8s/charts/hello
sed -i 's/\.Values\.replicas }}/.Values.replicaCount }}/' templates/deployment.yaml
sed -i 's/\.Values\.image\.tag }}/.Values.image.version }}/' templates/deployment.yaml   # или переименовать ключ в values
sed -i 's|/usr/share/nginx/html/index.htm$|/usr/share/nginx/html/index.html|' templates/deployment.yaml
helm lint .
helm upgrade --install hello . -n k05
helm history hello -n k05
kubectl -n k05 rollout status deploy/hello
```

## Доп. вопросы на собеседовании
- Что такое Helm, chart, release, revision? Где Helm 3 хранит состояние релиза? (Secret в namespace релиза)
- Как откатить релиз? (`helm rollback hello 1`)
- Чем `helm upgrade --install` удобен в CI? Что делают `--atomic` и `--wait`?
- Как передавать значения для разных окружений? (`-f values-prod.yaml`, порядок приоритета)
- Как отладить шаблон? (`helm template`, `--debug`, `helm get manifest`)
- Helm vs Kustomize?
