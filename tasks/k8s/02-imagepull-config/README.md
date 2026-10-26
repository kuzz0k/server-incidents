# k8s-02 · ImagePullBackOff и CreateContainerConfigError

**Уровень:** Junior · **Тема:** Kubernetes / поды · **Время:** ~15 мин

## Легенда
В namespace `k02` выкатили новую версию фронтенда (`deployment/frontend`, образ
`nginx:1.27-alpine`). Фронтенду нужен API-ключ из секрета `frontend-secrets` в переменной
окружения `API_KEY`. Поды не стартуют.

## Задача
Добейся, чтобы все поды фронтенда были Ready и получали правильный ключ.

## Ограничения
- Значение ключа в секрете не менять.

## Критерии готовности (что проверяет check)
- `deployment/frontend` доступен, все реплики Ready
- в контейнере `API_KEY` совпадает со значением из секрета

> Теория по теме — [THEORY.md](THEORY.md) (`sudo ./trainer.sh theory k8s-02`).
> Не читай `break.sh` и `check.sh` — там спойлеры.
