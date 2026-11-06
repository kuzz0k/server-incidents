# linux-52 · Сотрудника не пускает по SSH после отпуска

**Уровень:** Junior · **Тема:** Linux / пользователи, SSH · **Время:** ~15 мин

## Легенда
Аналитик вернулся из долгого отпуска и не может зайти на сервер под `reporter`. Права на `~/.ssh`
в порядке, ключ правильный. Его приватный ключ для проверки — `/root/trainer-keys/reporter_ed25519`:
```bash
ssh -i /root/trainer-keys/reporter_ed25519 -o StrictHostKeyChecking=no reporter@127.0.0.1 id
```
(если sshd слушает другой порт — добавь `-p <порт>`)

## Задача
Верни аналитику доступ по ключу.

## Ограничения
- `sshd_config` не менять.
- Ключ аналитика не перегенерировать и не удалять его из `authorized_keys`.

## Критерии готовности (что проверяет check)
- `ssh -i reporter_ed25519 reporter@127.0.0.1 id -un` → `reporter`
- срок действия учётки не истёк
- в `authorized_keys` по-прежнему тот же ключ

> Теория по теме — [THEORY.md](THEORY.md) (`sudo ./trainer.sh theory linux-52`).
> Не читай `break.sh` и `check.sh` — там спойлеры.
