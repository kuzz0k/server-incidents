# linux-37 · Разбор

## Шаги диагностики
1. `apt-get install -f` или любая установка → `dpkg: error processing package checkout-agent (--configure): installed checkout-agent package post-installation script subprocess returned error exit status 1`.
2. Состояние пакета: `dpkg -l checkout-agent` → `iF` (installed, half-configured), `dpkg --audit`.
3. Что делает postinst: `cat /var/lib/dpkg/info/checkout-agent.postinst`. Чего ему не хватает — видно из сообщения при `dpkg --configure checkout-agent`:
   - нет файла настроек `/etc/checkout-agent/agent.env` (пример лежит в `/usr/share/checkout-agent/`);
   - нет системного пользователя `checkout`.
4. Файлы пакета: `dpkg -L checkout-agent`.

## Решение
```bash
useradd --system --no-create-home --shell /usr/sbin/nologin checkout
mkdir -p /etc/checkout-agent
cp /usr/share/checkout-agent/agent.env.example /etc/checkout-agent/agent.env
dpkg --configure -a            # или: apt-get install -f
dpkg --audit
systemctl status checkout-agent
```

## Доп. вопросы на собеседовании
- Что значат буквы в `dpkg -l` (`ii`, `iF`, `iU`, `rc`)?
- Какие maintainer-скрипты бывают (preinst, postinst, prerm, postrm) и когда выполняются?
- Чем `dpkg --configure -a` отличается от `apt-get install -f`?
- Что делать, если упал `unattended-upgrades` посреди обновления?
- Как посмотреть, какие файлы ставит пакет, и из какого пакета файл? (`dpkg -L`, `dpkg -S`)
- `remove` vs `purge`?
