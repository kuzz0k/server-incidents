# ansible-01 · Разбор

Ошибки находятся по очереди, каждая — после исправления предыдущей.

1. **YAML:** `ansible-playbook --syntax-check` → `mapping values are not allowed here` / `did not find expected key`.
   У `mode:` в задаче `file` лишний отступ. YAML чувствителен к пробелам, табы нельзя.
2. **Шаблон:** `Could not find or access 'templates/status.conf.j2'` — файл называется `templates/status.j2`.
3. **Переменная:** `'status_port' is undefined` — в `group_vars/web.yml` она названа `statusport`.
   Правильнее исправить имя в group_vars (переменная используется в шаблоне).
4. **Хендлер:** `The requested handler 'reload nginx' was not found` — имена хендлеров чувствительны к регистру (`Reload nginx`).
   Сам хендлер срабатывает только при `changed` у задачи, которая его уведомила.

```bash
cd /opt/trainer-ansible/status-site
sed -i 's/^       mode:/        mode:/' site.yml
sed -i 's|templates/status.conf.j2|templates/status.j2|' site.yml
sed -i 's/^statusport:/status_port:/' group_vars/web.yml
sed -i 's/notify: reload nginx/notify: Reload nginx/' site.yml
ansible-playbook -i inventory.ini site.yml
ansible-playbook -i inventory.ini site.yml     # changed=0
curl http://127.0.0.1:8888/
```
Полезное при отладке: `-vvv`, `--check --diff`, `--start-at-task`, `--step`, `ansible-inventory --graph`,
`ansible -m debug -a var=hostvars[inventory_hostname]`, `ansible-lint`.

## Доп. вопросы на собеседовании
- Что такое идемпотентность и почему `shell` её ломает? Как сделать `shell` идемпотентным? (`creates:`, `changed_when:`)
- Что такое handlers и когда они выполняются? Что делает `meta: flush_handlers`?
- Приоритет переменных: group_vars, host_vars, vars в плейбуке, `-e`?
- Роли: структура каталогов, `defaults` vs `vars`?
- Как хранить секреты? (`ansible-vault`)
- Push-модель Ansible vs pull (Puppet/Chef)? Что нужно на управляемом хосте? (SSH + Python)
