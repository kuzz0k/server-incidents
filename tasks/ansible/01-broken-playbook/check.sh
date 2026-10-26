#!/usr/bin/env bash
set -uo pipefail
TASK_ID=ansible-01
. "$(dirname "$0")/../../../lib/check.sh"

P=/opt/trainer-ansible/status-site
export ANSIBLE_NOCOLOR=1 ANSIBLE_HOST_KEY_CHECKING=False
play() { (cd "$P" && ansible-playbook -i inventory.ini site.yml) 2>&1; }
RUN1=$(play); RC1=$?
RUN2=$(play); RC2=$?
second_clean() { (( RC2 == 0 )) && grep -Eq 'changed=0 +unreachable=0 +failed=0' <<<"$RUN2"; }
page_ok() { sleep 1; curl -fsS --max-time 5 http://127.0.0.1:8888/ | grep -qx "status: ok $(hostname -s)"; }
port_var() { grep -Eqs '^\s*status_port\s*:\s*8888' "$P"/group_vars/*.yml "$P"/group_vars/*/*.yml; }
no_shell() {
  python3 - "$1" <<'PY'
import sys, yaml
bad = {m for b in ("shell", "command", "raw") for m in (b, "ansible.builtin." + b, "ansible.legacy." + b)}
def tasks(play):
    for key in ("tasks", "handlers", "pre_tasks", "post_tasks"):
        for t in play.get(key) or []:
            yield t
            for sub in ("block", "rescue", "always"):
                yield from (t.get(sub) or [])
found = [t.get("name", "?") for play in yaml.safe_load(open(sys.argv[1])) or [] for t in tasks(play) if bad & set(t)]
sys.exit(1 if found else 0)
PY
}

check "syntax-check проходит" bash -c "cd $P && ansible-playbook -i inventory.ini site.yml --syntax-check"
check "первый прогон без ошибок" test "$RC1" -eq 0
check "повторный прогон: changed=0, failed=0" second_clean
check "страница на 8888: status: ok <hostname>" page_ok
check "порт задан переменной status_port в group_vars" port_var
check "без shell/command/raw" no_shell "$P/site.yml"
finish
