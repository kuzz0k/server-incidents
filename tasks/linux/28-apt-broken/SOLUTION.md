# linux-28 · Разбор

## Шаги диагностики
1. `apt-get update` → `E: Malformed entry 1 in list file /etc/apt/sources.list.d/vendor-tools.list ([option] not terminated)`.
2. `cat` этого файла — незакрытая `[` в опциях. Репозиторий вендора всё равно не существует → удаляем файл (или чиним синтаксис и `signed-by`).
3. `apt-get install jq` → `Could not get lock /var/lib/dpkg/lock-frontend. It is held by process NNN (apt-autoupdate)`.
4. Кто это: `ps -fp NNN`, `systemctl status NNN` → `apt-autoupdate.service`. `fuser -v /var/lib/dpkg/lock-frontend` тоже покажет.
5. Убить процесс мало: у юнита `Restart=always`, он вернётся. Нужно остановить и выключить сервис.

## Решение
```bash
rm /etc/apt/sources.list.d/vendor-tools.list
systemctl disable --now apt-autoupdate
fuser -v /var/lib/dpkg/lock-frontend          # пусто
apt-get update
apt-get install -y jq tree
```
Если блокировку держит настоящий `unattended-upgrades` — лучше дождаться его окончания, а не убивать: прерванный dpkg придётся чинить `dpkg --configure -a`.

## Как не допустить снова
- Добавлять репозитории в формате deb822 (`.sources`) с `Signed-By`, проверять `apt-get update` сразу.
- Не ставить на сервер «агентов» неизвестного происхождения.

## Доп. вопросы на собеседовании
- Чем `apt` отличается от `apt-get` и `dpkg`?
- Что делать, если видишь `dpkg was interrupted, you must manually run 'dpkg --configure -a'`?
- Как зафиксировать версию пакета? (`apt-mark hold`, pinning в `/etc/apt/preferences.d`)
- Как узнать, из какого пакета файл, и какие файлы в пакете? (`dpkg -S`, `dpkg -L`)
- Как правильно добавить сторонний репозиторий и его GPG-ключ? Почему `apt-key` устарел?
- Как посмотреть историю установок? (`/var/log/apt/history.log`)
