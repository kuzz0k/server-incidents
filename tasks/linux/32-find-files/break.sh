#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-32
. "$(dirname "$0")/../../../lib/common.sh"

R=/srv/shop
ORPHAN_UID=4242
while getent passwd "$ORPHAN_UID" >/dev/null; do ORPHAN_UID=$((ORPHAN_UID + 1)); done
rm -rf "$R"
mkdir -p "$R"/{app/conf.d,app/static,var/cache/.old,var/log,releases/{2023,2024,2025},uploads}

# фон: много старых файлов
for d in app/static releases/2023 releases/2024 releases/2025 uploads var/log; do
  for i in $(seq 1 300); do echo "$d $i" > "$R/$d/file-$i.dat"; done
done
for n in nginx php-fpm redis cron mail queue search cache; do echo "# $n" > "$R/app/conf.d/$n.conf"; done
echo "# main" > "$R/app/shop.conf"
find "$R" -exec touch -d '2025-03-01 12:00' {} +

# находки
truncate -s 120M "$R/var/cache/.old/catalog-dump.bin"
touch -d '2025-03-01 12:00' "$R/var/cache/.old/catalog-dump.bin"
truncate -s 90M "$R/releases/2025/assets.tar"
touch -d '2025-03-01 12:00' "$R/releases/2025/assets.tar"
echo "workers=8" >> "$R/app/conf.d/php-fpm.conf"
echo "maxmemory 2gb" >> "$R/app/conf.d/redis.conf"
echo "listen 8080;" >> "$R/app/shop.conf"
echo "tmp" > "$R/uploads/tmp-export.csv"; chmod 0666 "$R/uploads/tmp-export.csv"
touch -d '2025-03-01 12:00' "$R/uploads/tmp-export.csv"
chown "$ORPHAN_UID:$ORPHAN_UID" "$R/releases/2024/file-17.dat"
chmod 0777 "$R/releases"   # каталог, а не файл: в ответ не входит
