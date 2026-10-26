# k8s-05 · Helm-чарт ставится, но приложение не работает

**Уровень:** Middle · **Тема:** Kubernetes / Helm · **Время:** ~25 мин

## Легенда
Чарт `hello` лежит в `/opt/trainer-k8s/charts/hello`. Релиз установлен так:
```bash
helm upgrade --install hello /opt/trainer-k8s/charts/hello -n k05 --create-namespace
```
По задумке (см. `values.yaml`) это 3 реплики nginx, которые отдают страницу с текстом из
`values.yaml` (`message`). На деле под один, и тот не стартует.

## Задача
Почини **чарт** и обнови релиз той же командой, чтобы работали 3 реплики и отдавали `hello from helm`.

## Ограничения
- Исправления — в шаблонах и values чарта, а не через `--set`/`-f` при установке.
- Релиз должен остаться helm-релизом `hello` в namespace `k05` (не `kubectl apply` руками).

## Критерии готовности (что проверяет check)
- `helm lint` чарта без ошибок, релиз `hello` в статусе `deployed`
- у deployment 3 готовые реплики, под отдаёт страницу с `hello from helm`
- у релиза нет пользовательских values (`helm get values hello -n k05` пусто)

> Теория по теме — [THEORY.md](THEORY.md) (`sudo ./trainer.sh theory k8s-05`).
> Не читай `break.sh` и `check.sh` — там спойлеры.
