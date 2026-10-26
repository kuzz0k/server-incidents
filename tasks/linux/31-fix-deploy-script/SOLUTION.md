# linux-31 · Разбор

## Шаги
1. `./deploy.sh` → `/bin/bash^M: bad interpreter`. `file deploy.sh` → `with CRLF line terminators`; `cat -A deploy.sh` покажет `^M$`.
   Лечится `dos2unix deploy.sh` или `sed -i 's/\r$//' deploy.sh`.
2. `bash -x deploy.sh` без аргументов → `[: ==: unary operator expected`: незаключённая в кавычки пустая переменная исчезает.
   Правильно: `[[ -z $VERSION ]]` или `[ -z "$VERSION" ]`.
3. `bash -x deploy.sh 1.2.3` → `mkdir -p /opt/deploy/release store/1.2.3` создаёт **два** каталога: `/opt/deploy/release` и `./store/1.2.3`. Без кавычек переменная с пробелом разбивается на слова.
4. `deploy.sh 9.9.9` — `tar` падает, но скрипт продолжает и переключает `current` на пустой каталог: нет `set -e` и проверки артефакта.

## Исправленный скрипт
```bash
#!/bin/bash
# Деплой релиза: deploy.sh <version>
set -euo pipefail

VERSION=${1:-}
BASE=/opt/deploy
RELEASES="$BASE/release store"
ARTIFACT="$BASE/artifacts/app-$VERSION.tar.gz"

if [[ -z $VERSION ]]; then
  echo "usage: deploy.sh <version>" >&2
  exit 1
fi
if [[ ! -f $ARTIFACT ]]; then
  echo "artifact $ARTIFACT not found" >&2
  exit 2
fi

mkdir -p "$RELEASES/$VERSION"
tar -xzf "$ARTIFACT" -C "$RELEASES/$VERSION"
ln -sfn "$RELEASES/$VERSION" "$BASE/current"
echo "deployed $VERSION"
```

## Доп. вопросы на собеседовании
- Что такое word splitting и globbing? Почему «всегда бери переменные в кавычки»?
- Чем `[ ]` отличается от `[[ ]]`?
- Зачем `ln -sfn` и почему без `-n` при существующем симлинке на каталог получится не то?
- Как сделать переключение релиза атомарным? (`ln -s new tmp && mv -T tmp current`)
- Что проверяет `shellcheck` и как встроить его в CI?
- Как откатиться на предыдущий релиз в такой схеме?
