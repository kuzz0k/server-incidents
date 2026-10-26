#!/usr/bin/env bash
# Эталонное решение linux-29 (для tests/selftest.sh)
set -euo pipefail
LOG=/var/log/trainer/access.log
mkdir -p /root/answers
{
  awk '{print $1}' $LOG | sort | uniq -c | sort -rn | head -3 | awk '{print "top_ip" NR "=" $2}'
  echo "errors_5xx=$(awk '$9 ~ /^5/' $LOG | wc -l)"
  echo "top_404_url=$(awk '$9 == 404 {print $7}' $LOG | sort | uniq -c | sort -rn | head -1 | awk '{print $2}')"
  echo "unique_ips_14h=$(awk '{split($4, t, ":"); if (t[2] == "14") print $1}' $LOG | sort -u | wc -l)"
} > /root/answers/linux-29.txt
