#!/usr/bin/env bash
# Набор файлов для linux-43 (используют break.sh и check.sh)
set -euo pipefail
D=/var/log/app-cleaner
rm -rf "$D"
mkdir -p "$D"
mk() { printf 'log line\n' > "$D/$1"; touch -d "$2" "$D/$1"; }
mk "api.log"                     "-2 hours"
mk "worker today.log"            "-3 hours"
mk "api-old.log"                 "-2 days"
mk "worker 2026-old.log"         "-5 days"
mk "billing.log"                 "-30 hours"
printf 'x' | gzip > "$D/api-recent.log.gz";      touch -d "-3 days"  "$D/api-recent.log.gz"
printf 'x' | gzip > "$D/api-week.log.gz";        touch -d "-6 days"  "$D/api-week.log.gz"
printf 'x' | gzip > "$D/api-ancient.log.gz";     touch -d "-20 days" "$D/api-ancient.log.gz"
printf 'x' | gzip > "$D/worker old 2.log.gz";    touch -d "-10 days" "$D/worker old 2.log.gz"
mk "README.txt"                  "-40 days"
