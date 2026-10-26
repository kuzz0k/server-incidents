#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-43
. "$(dirname "$0")/../../../lib/common.sh"

cat > /usr/local/bin/clean-logs.sh <<'EOF'
#!/bin/bash
# Чистка логов приложения: сжать логи старше суток, удалить архивы старше 7 дней
DIR=/var/log/app-cleaner
cd $DIR
for f in $(find . -name *.log -mtime 1); do gzip $f; done
rm -f $(find $DIR -name "*.gz" -mtime -7)
EOF
chmod 0755 /usr/local/bin/clean-logs.sh
bash "$(dirname "$0")/fixture.sh"
