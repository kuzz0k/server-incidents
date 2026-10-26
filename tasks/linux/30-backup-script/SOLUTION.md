# linux-30 · Разбор

## Эталонное решение
```bash
#!/usr/bin/env bash
# Бэкап каталога в tar.gz с ротацией: backup-app.sh [SRC] [DST]
set -euo pipefail

SRC=${1:-/srv/app-data}
DST=${2:-/var/backups/app-data}
KEEP=${KEEP:-5}

if [[ ! -d $SRC ]]; then
  echo "backup-app: source directory '$SRC' not found" >&2
  exit 2
fi

name=$(basename "$SRC")
mkdir -p "$DST"
archive="$DST/$name-$(date +%Y%m%d-%H%M%S).tar.gz"

# пишем во временный файл: недописанный архив не должен считаться бэкапом
tmp=$(mktemp "$DST/.$name.XXXXXX")
trap 'rm -f "$tmp"' EXIT
tar -czf "$tmp" -C "$(dirname "$SRC")" "$name"
mv "$tmp" "$archive"
trap - EXIT

# ротация: только архивы этого SRC, сортировка по имени = по времени
find "$DST" -maxdepth 1 -type f -name "$name-*.tar.gz" -printf '%f\n' \
  | sort -r | tail -n +"$((KEEP + 1))" \
  | while IFS= read -r old; do rm -f -- "$DST/$old"; done

logger -t backup-app "backup of $SRC saved to $archive (keep $KEEP)"
echo "$archive"
```

## На что обращают внимание
- `set -euo pipefail`, кавычки вокруг **всех** переменных, `--` перед именами файлов.
- Ошибки — в stderr и с ненулевым кодом, чтобы cron/CI их видели.
- Атомарность: архив сначала во временный файл, потом `mv`.
- Ротация не должна задевать чужие файлы. Не парсить `ls`.
- `tar -C`: в архиве относительные пути, а не `/srv/...`.

## Доп. вопросы на собеседовании
- Что делают `set -e`, `set -u`, `set -o pipefail`? Где `set -e` не срабатывает?
- Зачем `trap`? Какие сигналы можно поймать, а какие нет?
- Чем `$*` отличается от `"$@"`?
- Как не допустить двух одновременных запусков? (`flock -n /run/backup.lock`)
- Как проверить, что из бэкапа можно восстановиться? (тестовое восстановление!)
- Правило 3-2-1 для бэкапов. Почему бэкап на том же диске — не бэкап?
