#!/usr/bin/env bash
set -uo pipefail
TASK_ID=mysql-01
. "$(dirname "$0")/../../../lib/check.sh"

root_socket() { mysql -uroot -e 'select 1' >/dev/null 2>&1; }
app_user() { [[ $(mysql -ushop -pShop-Pass-2026 -NBe 'select count(*) from orders' shop 2>/dev/null) == 2000 ]]; }
no_global() { ! mysql -uroot -NBe "SHOW GRANTS FOR 'shop'@'localhost'" 2>/dev/null | grep -v 'GRANT USAGE ON \*\.\*' | grep -q 'ON \*\.\*'; }
normal_mode() { ! pgrep -af 'mariadbd|mysqld' | grep -q skip-grant && ! systemctl show-environment | grep -q skip-grant; }

check "root входит через unix-сокет без пароля" root_socket
check "shop.customers: 500 строк" bash -c "[[ \$(mysql -uroot -NBe 'select count(*) from shop.customers') == 500 ]]"
check "shop.orders: 2000 строк" bash -c "[[ \$(mysql -uroot -NBe 'select count(*) from shop.orders') == 2000 ]]"
check "shop@localhost с паролем читает orders" app_user
check "у shop нет глобальных привилегий" no_global
check "MariaDB работает в обычном режиме" normal_mode
finish
