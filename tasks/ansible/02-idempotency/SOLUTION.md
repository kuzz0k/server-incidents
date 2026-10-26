# ansible-02 · Разбор

## Решение
```yaml
- name: Base setup
  hosts: localhost
  connection: local
  become: true
  tasks:
    - name: Group appusers
      ansible.builtin.group:
        name: appusers
        state: present

    - name: User appuser
      ansible.builtin.user:
        name: appuser
        group: appusers
        shell: /bin/bash
        create_home: true

    - name: App directory
      ansible.builtin.file:
        path: /opt/app
        state: directory
        owner: appuser
        group: appusers
        mode: "0750"

    - name: MOTD line
      ansible.builtin.lineinfile:
        path: /etc/motd
        line: Managed by Ansible
        create: true
        mode: "0644"

    - name: Config directory
      ansible.builtin.file:
        path: /etc/app
        state: directory
        mode: "0755"

    - name: App config
      ansible.builtin.lineinfile:
        path: /etc/app/app.conf
        line: log_level=info
        create: true
        mode: "0644"
```
```bash
ansible-playbook /opt/trainer-ansible/base/base.yml
ansible-playbook /opt/trainer-ansible/base/base.yml     # ok=…, changed=0
```

## Почему модули идемпотентны
Модуль сначала проверяет текущее состояние и меняет только то, что отличается от желаемого, а потом
честно сообщает, было ли изменение (`changed`). `shell` ничего не знает о состоянии: команда просто
выполняется каждый раз. Если без `shell` никак: `creates:`/`removes:`, `changed_when:`, `failed_when:`.

## Доп. вопросы на собеседовании
- Что такое идемпотентность? Пример идемпотентной и неидемпотентной операции.
- `lineinfile` vs `blockinfile` vs `template`: когда что?
- Как проверить идемпотентность в CI? (Molecule: идемпотентный прогон)
- `--check` и `--diff`: как работают и где врут?
- Чем `command` отличается от `shell`?
