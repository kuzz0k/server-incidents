#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-32
. "$(dirname "$0")/../../../lib/check.sh"

R=/srv/shop
check "big_file" answer_is big_file "$R/var/cache/.old/catalog-dump.bin"
check "recent_configs" answer_is recent_configs "$R/app/conf.d/php-fpm.conf,$R/app/conf.d/redis.conf,$R/app/shop.conf"
check "world_writable" answer_is world_writable "$R/uploads/tmp-export.csv"
check "orphan_file" answer_is orphan_file "$R/releases/2024/file-17.dat"
check "в $R нет world-writable обычных файлов" bash -c "! find $R -type f -perm -o+w | grep -q ."
finish
