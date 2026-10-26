# k8s-06 · Фронтенд не достучался до базы в другом namespace

**Уровень:** Middle · **Тема:** Kubernetes / сеть, NetworkPolicy, DNS · **Время:** ~25 мин

## Легенда
Фронтенд (`deployment/frontend` в namespace `k06-app`) ходит в сервис `backend-db` из namespace `k06-db`
по адресу из переменной `DB_URL`. Безопасники включили в `k06-db` сетевые политики «запрещено всё,
кроме фронтенда магазина». После этого и переезда в отдельные namespace фронтенд пишет `fail`:
```bash
kubectl -n k06-app logs deploy/frontend --tail=5
```

## Задача
Добейся, чтобы фронтенд получал ответ `db ok` от `backend-db`.

## Ограничения
- Политику `default-deny-ingress` в `k06-db` не удалять и не ослаблять.
- Не открывать доступ к базе всем: под из чужого namespace (даже с такими же метками) должен оставаться заблокирован.
- `backend-db` не трогать.

## Критерии готовности (что проверяет check)
- из пода фронтенда `wget -qO- "$DB_URL"` → `db ok`
- `default-deny-ingress` на месте
- тестовый под с меткой `role=frontend` из namespace `k06-other` до базы не достучится

> Теория по теме — [THEORY.md](THEORY.md) (`sudo ./trainer.sh theory k8s-06`).
> Не читай `break.sh` и `check.sh` — там спойлеры.
