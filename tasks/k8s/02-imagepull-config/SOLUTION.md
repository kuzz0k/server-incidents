# k8s-02 · Разбор

## Шаги диагностики
1. `kubectl -n k02 get pods` → `ErrImagePull` / `ImagePullBackOff`.
2. `kubectl -n k02 describe pod <pod>` → Events: `Failed to pull image "nginx:1.27-alpinee": ... not found`. Опечатка в теге.
3. После исправления образа: `CreateContainerConfigError`. В describe: `couldn't find key api_key in Secret k02/frontend-secrets`.
4. `kubectl -n k02 get secret frontend-secrets -o jsonpath='{.data}'` — ключ называется `api-key`.

## Решение
```bash
kubectl -n k02 set image deploy/frontend frontend=nginx:1.27-alpine
kubectl -n k02 edit deploy frontend      # secretKeyRef.key: api-key
kubectl -n k02 rollout status deploy/frontend
kubectl -n k02 exec deploy/frontend -- printenv API_KEY
```

## Как не допустить снова
- Фиксировать образы по тегу/дайджесту, проверять существование образа в CI.
- Генерировать манифесты из шаблонов (Helm/Kustomize) и валидировать до деплоя.

## Доп. вопросы на собеседовании
- Чем ImagePullBackOff отличается от ErrImagePull? Какие ещё причины? (приватный registry без `imagePullSecrets`, rate limit Docker Hub, нет сети)
- Что такое `imagePullPolicy` и почему `latest` — плохая идея?
- Secret vs ConfigMap. Безопасны ли Secret? (base64, шифрование etcd, RBAC, External Secrets/Vault)
- Как передать секрет: env или volume? Что произойдёт при изменении Secret в каждом случае?
- Как откатить деплой? (`kubectl rollout undo`, `rollout history`)
