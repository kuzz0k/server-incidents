#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-51
. "$(dirname "$0")/../../../lib/common.sh"

remove_unit payment-gw
rm -rf /var/lib/payment-gw
mkdir -p "$TRAINER_LIB" /var/lib/payment-gw
order="ORD-$(shuf -i 100000-999999 -n 1)"
echo "$order" > "$TASK_VAR/order"
cat > "$TRAINER_LIB/payment-gw.py" <<EOF
#!/usr/bin/env python3
# Платёжный шлюз (учебный): пишет логи, первые 3 запуска падают
import random, sys, time
runs_file = "/var/lib/payment-gw/runs"
try:
    runs = int(open(runs_file).read())
except Exception:
    runs = 0
open(runs_file, "w").write(str(runs + 1))
for i in range(400):
    oid = f"ORD-{random.randint(100000, 999999)}"
    if runs == 2 and i == 200:
        print("<3>ERROR payment declined by acquirer order_id=$order code=51", flush=True)
    elif i % 37 == 0:
        print(f"<4>WARN slow acquirer response 2.3s order_id={oid}", flush=True)
    else:
        print(f"<6>INFO payment ok order_id={oid} error_count=0 retries=0", flush=True)
    time.sleep(0.005)
if runs < 3:
    print("<6>INFO upstream connection lost, exiting", flush=True)
    sys.exit(3)
while True:
    time.sleep(3600)
EOF
write_unit payment-gw <<EOF
[Unit]
Description=Payment gateway
StartLimitIntervalSec=0

[Service]
ExecStart=/usr/bin/python3 $TRAINER_LIB/payment-gw.py
Restart=on-failure
RestartSec=1

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now payment-gw >/dev/null 2>&1
wait_until 60 bash -c '[[ $(cat /var/lib/payment-gw/runs 2>/dev/null) == 4 ]]'
sleep 3
journalctl -u payment-gw -p err -o short-iso --no-pager -q | grep -F "$order" | head -1 \
  | sed -E 's/^[0-9-]+T([0-9:]+).*/\1/' > "$TASK_VAR/time"
systemctl show -p NRestarts --value payment-gw > "$TASK_VAR/restarts"
