#!/usr/bin/env bash
set -uo pipefail
TASK_ID=linux-26
. "$(dirname "$0")/../../../lib/check.sh"

SWAP=/var/lib/swap/trainer.swap
swap_size_ok() { local b; b=$(swapon --show=NAME,SIZE --bytes --noheadings | awk -v f="$SWAP" '$1 == f {print $2}'); [[ -n $b ]] && (( b >= 500 * 1024 * 1024 )); }
persisted() { grep -rhsE '^\s*vm\.swappiness\s*=\s*10\s*$' /etc/sysctl.conf /etc/sysctl.d/ | grep -q .; }

check "$SWAP активен" bash -c "swapon --show=NAME --noheadings | grep -qx $SWAP"
check "размер swap не меньше 500 MiB" swap_size_ok
check "права на файл 600" bash -c "[[ \$(stat -c %a $SWAP) == 600 ]]"
check "запись в /etc/fstab" bash -c "awk '\$1 !~ /^#/ && \$1 == \"$SWAP\" && \$3 == \"swap\"' /etc/fstab | grep -q ."
check "vm.swappiness = 10 сейчас" bash -c "[[ \$(sysctl -n vm.swappiness) == 10 ]]"
check "vm.swappiness = 10 сохранён в sysctl-конфиге" persisted
finish
