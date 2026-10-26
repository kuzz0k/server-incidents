#!/usr/bin/env bash
set -euo pipefail
TASK_ID=linux-29
. "$(dirname "$0")/../../../lib/common.sh"

mkdir -p /var/log/trainer
python3 - /var/log/trainer/access.log <<'EOF'
import random, sys
rnd = random.Random(20261020)
ips = [f"{rnd.randint(11, 220)}.{rnd.randint(0, 255)}.{rnd.randint(0, 255)}.{rnd.randint(1, 254)}" for _ in range(400)]
heavy = {ips[0]: 2600, ips[1]: 2100, ips[2]: 1700}
urls = ["/", "/catalog", "/catalog/phones", "/cart", "/checkout", "/api/v1/products", "/api/v1/cart",
        "/static/app.js", "/static/app.css", "/login", "/search?q=tv", "/favicon.ico"]
missing = ["/old-promo", "/wp-login.php", "/.env", "/catalog/discontinued", "/robots.txt"]
agents = ["Mozilla/5.0 (X11; Linux x86_64)", "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_5)",
          "curl/8.5.0", "Googlebot/2.1 (+http://www.google.com/bot.html)"]

def line(ip, hour):
    status = rnd.choices([200, 301, 304, 404, 500, 502, 503], [80, 3, 6, 5, 2, 2, 2])[0]
    if status == 404:
        url = rnd.choices(missing, [5, 9, 3, 2, 1])[0]
    else:
        url = rnd.choice(urls)
    size = 0 if status == 304 else rnd.randint(200, 90000)
    t = f"20/Oct/2026:{hour:02d}:{rnd.randint(0, 59):02d}:{rnd.randint(0, 59):02d} +0000"
    return f'{ip} - - [{t}] "GET {url} HTTP/1.1" {status} {size} "-" "{rnd.choice(agents)}"'

rows = []
for ip, n in heavy.items():
    rows += [(rnd.randint(0, 23), ip) for _ in range(n)]
rows += [(rnd.choices(range(24), [1] * 14 + [6] + [1] * 9)[0], rnd.choice(ips[3:])) for _ in range(43600)]
rows.sort(key=lambda r: r[0])
with open(sys.argv[1], "w") as f:
    for hour, ip in rows:
        f.write(line(ip, hour) + "\n")
EOF
