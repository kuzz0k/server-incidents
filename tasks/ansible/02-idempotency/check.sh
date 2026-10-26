#!/usr/bin/env bash
set -uo pipefail
TASK_ID=ansible-02
. "$(dirname "$0")/../../../lib/check.sh"

PB=/opt/trainer-ansible/base/base.yml
export ANSIBLE_NOCOLOR=1 ANSIBLE_LOCALHOST_WARNING=False ANSIBLE_INVENTORY_UNPARSED_WARNING=False

# Чистое состояние, затем два прогона
remove_user appuser
getent group appusers >/dev/null && groupdel appusers
rm -rf /opt/app /etc/app
sed -i '/^Managed by Ansible$/d' /etc/motd 2>/dev/null
RUN1=$(ansible-playbook "$PB" 2>&1); RC1=$?
RUN2=$(ansible-playbook "$PB" 2>&1); RC2=$?

second_clean() { (( RC2 == 0 )) && grep -Eq 'changed=0 +unreachable=0 +failed=0' <<<"$RUN2"; }
user_ok() {
  [[ $(id -gn appuser 2>/dev/null) == appusers ]] && [[ $(getent passwd appuser | cut -d: -f7) == /bin/bash ]] \
    && [[ -d $(getent passwd appuser | cut -d: -f6) ]]
}
dir_ok() { [[ $(stat -c '%U:%G %a' /opt/app 2>/dev/null) == 'appuser:appusers 750' ]]; }
once() { [[ $(grep -cx "$2" "$1" 2>/dev/null) == 1 ]]; }
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

check "первый прогон успешен" test "$RC1" -eq 0
check "второй прогон успешен и changed=0" second_clean
check "appuser: группа appusers, /bin/bash, home" user_ok
check "/opt/app: appuser:appusers 0750" dir_ok
check "/etc/motd: строка ровно одна" once /etc/motd "Managed by Ansible"
check "/etc/app/app.conf: log_level=info ровно одна" once /etc/app/app.conf "log_level=info"
check "/etc/app: права 0755" bash -c "[[ \$(stat -c %a /etc/app) == 755 ]]"
check "без shell/command/raw" no_shell "$PB"
finish
