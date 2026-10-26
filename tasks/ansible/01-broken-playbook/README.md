# ansible-01 · Починить плейбук Ansible

**Уровень:** Middle · **Тема:** Ansible · **Время:** ~25 мин

## Легенда
Проект `/opt/trainer-ansible/status-site` должен поднимать на этом сервере (inventory — сам сервер,
`ansible_connection=local`) страницу статуса на nginx, порт **8888**: текст `status: ok <hostname>`.
Автор проекта уволился, плейбук не отрабатывает.

Запуск:
```bash
cd /opt/trainer-ansible/status-site
ansible-playbook -i inventory.ini site.yml
```

## Задача
Почини проект, чтобы плейбук проходил без ошибок, страница открывалась, а повторный запуск ничего не менял.

## Ограничения
- Значения переменных (`group_vars/`) не переносить в плейбук: они должны браться из переменных группы.
- Не заменять модули на `shell`/`command`.

## Критерии готовности (что проверяет check)
- `ansible-playbook --syntax-check` и обычный прогон проходят
- `curl http://127.0.0.1:8888/` → `status: ok <hostname>`
- повторный прогон: `changed=0`, `failed=0`
- порт 8888 задаётся переменной из `group_vars/`

> Теория по теме — [THEORY.md](THEORY.md) (`sudo ./trainer.sh theory ansible-01`).
> Не читай `break.sh` и `check.sh` — там спойлеры.
